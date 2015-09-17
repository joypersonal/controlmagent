# Basic tests for the retrieval and extracting of the 
# intallation file only

class { 'controlmagent::archive':
  arch_used   => true,
  $arch_url   => 'file://vagrant',
  $arch_dir   => '/tmp',
  $tempdir    => '/tmp',
  $tarFile    => 'DRKAI.8.0.00_Linux-x86_64.tgz',
  $extractDir => 'Linux-x86_64',
}
