# Class: controlmagent
#
# This module silently installs Control-M/Agent 8 on Linux/UNIX
#
# version 0.0.7: 26 November 2014 by Tomasz Wladyczanski
#
# https://www.linkedin.com/in/tomekw
# http://uid-0.blogspot.com
#
# Module parameters and their defaults:
#
# userLogin => 'root',                        # user account for which Control-M/Agent 8 will be installed
# installLogin => 'root',                     # user account which will install Control-M/Agent 8 (and default mode of the agent) 
# tarFile => 'DRKAI.8.0.00_Linux-i386.tar.Z', # installation tar file
# installVersion => 'DRKAI.8.0.00'            # installed version to check in the installed-versions.txt
# installDir => '~',                          # directory where Control-M/Agent 8 will be installed 
# tempDir => '/tmp/CONTROLM_AGENT',           # directory where the tar file will be placed and unpacked
# authorizedServers => '',                    # Control-M/Agent 8 parameters (for the silent installation)
# primaryServer => '',                        # ...
# trackerEventPort => 7035,                   # ...
# agentToServer => 7005,                      # ...
# tcpIpTimeout => 60,                         # ...
# serverToAgent => 7006,                      # ...
# disablingAgentFailure => false              # .
class controlmagent (
  $userLogin             = 'root',
  $installLogin          = 'root',
  $tarFile               = 'DRKAI.8.0.00_Linux-i386.tar.Z',
  $installVersion        = 'DRKAI.8.0.00',
  $installDir            = '~',
  $tempDir               = '/tmp/CONTROLM_AGENT',
  $authorizedServers     = '',
  $primaryServer         = '',
  $trackerEventPort      = 7035,
  $agentToServer         = 7005,
  $tcpIpTimeout          = 60,
  $serverToAgent         = 7006,
  $disablingAgentFailure = false )
{

  Exec['controlmagent: Check']           ->
  Exec['controlmagent: Prepare']         ->
  File['Control-M/Agent 8 tar.Z file']   ->
  File['controlm_agent_silent.xml']      ->
  Exec['controlmagent: Extract tar']     ->
  Exec['controlmagent: Make target dir'] ->
  Exec['controlmagent: Run installer']


  exec {'controlmagent: Check':
    path    => '/bin:/usr/bin',
    command => "su - ${userLogin} -c \"find ~/installed-versions.txt | xargs grep \"${installVersion}\"\"",
    returns => 123,
#    unless   => "su - ${userLogin} -c \"find ~/installed-versions.txt | xargs grep \"DRKAI.8.0.00\"\"",
#    command  => "su - ${installLogin} -c \"mkdir -p ${tempDir}\"",
  }

  exec {'controlmagent: Prepare':
    path    => '/bin:/usr/bin',
    command => "su - ${installLogin} -c \"mkdir -p ${tempDir}\"",
#    command  => "su - ${installLogin} -c \"test -d ${tempDir}\"",
  }

file { 'Control-M/Agent 8 tar.Z file':
    owner  => $installLogin,
    mode   => '0755',
    source => "puppet:///files/${tarFile}",
    path   => "${tempDir}/${tarFile}"
  }

  file { 'controlm_agent_silent.xml':
    owner   => $installLogin,
    mode    => '0644',
    path    => "${tempDir}/controlm_agent_silent.xml",
    content => template('controlmagent/controlm_agent_silent.xml.erb'),
  }

  exec { 'controlmagent: Extract tar':
    path    => '/bin:/usr/bin',
    onlyif  => "test -f ${tempDir}/${tarFile}",
    command => "su - ${installLogin} -c \"tar -C ${tempDir} -xzf ${tempDir}/${tarFile}\"",
  }

  exec { 'controlmagent: Make target dir':
    path    => '/bin:/usr/bin',
    unless  => "su - ${userLogin} -c \"test -d ${installDir}\"",
    command => "su - ${userLogin} -c \"mkdir -p ${installDir}\"",
  }

  exec { 'controlmagent: Run installer':
    path    => '/bin:/usr/bin',
    onlyif  => "su - ${userLogin} -c \"test -d ${installDir}\"",
    command => "su - ${installLogin} -c \"cd `su - ${userLogin} -c \"echo ${installDir}\"` ; ${tempDir}/setup.sh -silent ${tempDir}/controlm_agent_silent.xml\"",
  }

  #maybe to write later
  #service { ‘controlm_agent service’:
    #ensure => running,
    #name   => 'controlm_agent',
    #enable => true,
  #}
}
