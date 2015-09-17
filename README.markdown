The controlmagent module is for installation of BMC Control-M/Agent 8 on Linux/UNIX.

Based on version 0.0.7: 26 November 2014 by Tomasz Wladyczanski

https://www.linkedin.com/in/tomekw
http://uid-0.blogspot.com

Module parameters and their defaults:

; user account for which Control-M/Agent 8 will be installed
userLogin => 'root',

; user account which will install Control-M/Agent 8 (and default mode of the agent)
installLogin => 'root',

; installation tar file
tarFile => 'DRKAI.8.0.00_Linux-i386.tar.Z',

; installed version to check in the installed-versions.txt
installVersion => 'DRKAI.8.0.00'

; directory where Control-M/Agent 8 will be installed
installDir => '~',

; directory where the tar file will be placed and unpacked
tempDir => '/tmp/CONTROLM_AGENT',

; Control-M/Agent 8 parameters (for the silent installation)
authorizedServers => '',
primaryServer => '',
trackerEventPort => 7035,
agentToServer => 7005,
tcpIpTimeout => 60,
serverToAgent => 7006,
disablingAgentFailure => false,
