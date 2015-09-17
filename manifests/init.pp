class controlmagent (
  # Class: controlmagent
  #
  # This module silently installs Control-M/Agent 8 on Linux/UNIX
  #
  # Based on version 0.0.7: 26 November 2014 by Tomasz Wladyczansk
  # Mofified by Johan De Wit <Johan@koewacht.net> 2015
  #
  # https://www.linkedin.com/in/tomekw
  # http://uid-0.blogspot.com
  #
  # Module parameters and their defaults:
  #
  # Installation  program must be started form the controlm user's home dir
  # Can be done in two modes " user or root mode --> add a parameter
  # No rc.script installed by default, but example one is provided
  # need an xml file otherwise interactive isntallation:
  # 64bit version needs an environment variable set : INSTALL_AGENT_LINUX_X86_64="Y"
  #
  # Tarballs should be created for every supported os/ARCH from the ISO 
  # provided by BMC.  
  # 

  #
  # provided rc.agent_user starupscript is not 'service' compliant
  #
  #  Features to look at :
  #  Managing the CTM-AGENT
  #  - set agent mode
  #  - service stop/start/etc....
  #  - install extentions ....
  #
  # retreiving and extracting the installation archive
  # $arch_used             = true,    // is the tarbal retrieval handeld byh the archive provider ?
  # $arch_url              = '',      // the url where to retrieve the tarbal form, will be combined with $tarFile
  # $arch_path             = $tempdir, // where to extract the archive
  # $arch_username         = undef,
  # $arch_password         = undef,
  # $arch_extract          = true,    // we need to extract it anyway
  # $arch_clean            = true,   // we remove the archive
  #
  # ## archive provisioning using archie ##
  #
  # tarFile               => 'DRKAI.8.0.00_Linux-i386.tgz',   # installation tar file (handled as a file resource)
  # installVersion        => 'DRKAI.8.0.00'                   # installed version to check in the installed-versions.txt
  # installDir            => '~',                             # directory where Control-M/Agent 8 will be installed
  # tempDir               => '/tmp/CONTROLM_AGENT',           # directory where the tar file will be placed and unpacked
  #
  #  ## Control-m user management ##
  #
  # $manage_ctm_user      => true,                            # Manage the control-m user with this module ?
  #
  # ctm_user              => 'control-m',                     # The control-m user we need to create
  # ctm_uid               => undef,                           # use system default
  # ctm_gid               => undef,                           # use system default
  # ctm_shell             => undef,                           # use system default
  # run_as_root           => true,                            # by default, we run in 'root' mode
  #
  # ##  controlm installation settings ##
  #
  # authorizedServers     => '',                              # Control-M/Agent 8 parameters (for the silent installation)
  # primaryServer         => '',                              # ...
  # trackerEventPort      => 7035,                            # ...
  # agentToServer         => 7005,                            # ...
  # tcpIpTimeout          => 60,                              # ...
  # serverToAgent         => 7006,                            # ...
  # disablingAgentFailure => false                            # .
  #
  # ## manage teh startup/service with puppet ##
  #
  # manage_ctm_rc         => false,                           # we do not manage it by default
  # ctm_rc_template       => "rc.user_agent.erb",              # one can overrule the defalt startup script
  # ctm_rc_status         => undef,                           # To be defined when working on the service
  #
  $arch_used             = true,
  $arch_url              = '',
  $arch_path             = $tempdir,
  $arch_username         = undef,
  $arch_password         = undef,
  $arch_extract          = true,
  $arch_clean            = true,

  $manage_ctm_user       = true,                            # Manage the control-m user with this module ?
  $ctm_user              = 'control-m',                     # The control-m user we need to create
  $ctm_uid               = undef,                           # use system default
  $ctm_gid               = undef,                           # use system default
  $ctm_shell             = undef,                           # use system default

  $run_as_root           = true,

  $userLogin             = 'root',
  $installLogin          = 'root',
  $tarFile               = "DRKAI.8.0.00_Linux-${::architecture}.tgz",
  $installVersion        = 'DRKAI.8.0.00',
  $installDir            = '~',
  $extractDir            = "Linux-${::architecture}",
  $tempDir               = '/tmp/CONTROLM_AGENT',
  $authorizedServers     = '',
  $primaryServer         = '',
  $trackerEventPort      = 7035,
  $agentToServer         = 7005,
  $tcpIpTimeout          = 60,
  $serverToAgent         = 7006,
  $disablingAgentFailure = false ) inherits controlmagent::params
  {

    # system prerequisites
    if $manage_ctm_user {
      if $ctm_user == 'root' {
        fail("The Control-m agent needs a dedicated non root user to hold the installation files")
      }
      if !( $ctm_shell and $ctm_shell in ['/bin/csh','/bin/tcsh','/bin/sh','/bin/ksh','/bin/bash'] ) {
        fail("The choosen shell (${ctm_shell}) is not supported for the user ${ctm_user}")
      }

      # keep in mind we need proper requirements.  this user must exist before executing the installation
      user{ "$ctm_user":
        ensure     => 'present',
        managehome => 'true',
        home       => "/home/$ctm_user",
        uid        => $ctm_uid,
        gid        => $ctm_gid,
        shell      => $ctm_chell,
      }
    }

    if $arch_used {
      # using the archive module to transfer the archive to the node
      archive { "DRKAI_archive":
        ensure       => present,
        path         => "${arch_dir}/${tarFile}",
        extract      => true,
        extract_path => $tempdir,
        source       => "${arch_url}/${tarFile}",
        username     => $arch_username,
        password     => $arch_password,
        creates      => "${tempdir}/${extractDir}",
      }
    } else {
      # using plain file resource stuff
      # litlle hack borrowed from ghoneycutt/puppet-module-common
      # to avoid recurive directory troubles
      controlmagent::mkdir_p { $tempDir: }

      file { $tempDir:
        esnure  => present,
        require => Controlmagent::Mkdir_p[$tmpDir],
      }

      file { "${tempDir}/${tarFile}":
        ensure  => present,
        source  => "puppet:///modules/controlmagent/${tarFile}",
        require => File[$tempDir],
        notify  => Exec['extract_tarbal'],
      }

      exec { 'extract_tarbal':
        path        => '/bin:/usr/bin',
        onlyif      => "test -f ${tempDir}/${tarFile}",
        refreshonly => true,
        command     => "tar -C ${tempDir} -xzf ${tempDir}/${tarFile}",
      }
    }







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
