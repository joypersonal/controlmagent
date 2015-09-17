# ==== class controlmagent::archive
#
# Retrieves the file, and extracts it
#
# This is a private class and should not be called
# from outside this module
#
# ==== Parameters
#
#  TO ADD
#
class controlmagent::archive (
  $arch_used     = '',
  $arch_url      = '',
  $arch_dir      = '',
  $arch_username = '',
  $arch_password = '',
  $tempdir       = '',
  $tarFile       = '',
  $extractDir    = '', )
{

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
}
