controlmagent
=============

Puppet module for BMC Control-M/Agent 8 installation.

[Description in the Puppet Forge](https://forge.puppetlabs.com/tw/controlmagent)


Preparation installation files
==============================

The controlM agent software is not accessible without proper license.For the 8.x
version, BMC distributes its software as an ISO file of 2.5GB. This modules assumes
you extract the proper pieces to install as a tarball.  This is a short procedure 
to create those files form the ISO file :

```bash
 sudo mount -o loop DRKAI.8.0.00.iso /mnt
 cd /mnt/UNIX
 tar -czf /tmp/DRKAI.8.0.00_Linux-i386.tar.gz Linux-i386
 tar -czf /tmp/DRKAI.8.0.00_Linux-x86_64tar.gz Linux-x86_64
```
The tarbasl should be moved to a location accessible to the nodes.  By default, the 
archive puppet custom type is used.  Keep in mind that the sizes of the tarball could reach 150M, 
and the unpacked archives could reach above 200M on linux.

Getting the archive to the node
===============================

The default method is the [archive module](https://forge.puppetlabs.com/nanliu/archive).
This module does have the possiility to retrieve the file using http://,ftp:// or file://.
This last one could be handy when installation sources are provided using a mounted share.

Overview of the controlm agent module
=====================================

This module installs the control-m agents and follows the recommended installation procedure.

We do support both the installation/startup of the control-m agent in both 'user' or 'root' modus.
Optionally, this module can manage both the sysctl reccommended settings and manage the firewall of the
node itself.

The installation can be tuned using the following parameters :




