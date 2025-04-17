# @summary This is the main (and currently only) class for managing CNI plugins for the CNI plugins module
#
# This class downloads, extracts, and manages versions for the CNI plugins
# archives.
#
# @param version
#   The version of the CNI plugins to install (default: 1.6.2)
#
# @param install_root
#   The root into which the cni plugins should be installed (default: /opt/cni)
#
# @param install_root_mode
#   The permissions to give the install root directory (default: 0755)
#
# @param install_root_owner
#   The owner for the install root directory (default: root)
#
# @param install_root_group
#   The group for the install root directory (default: root)
#
# @example
#   include cni_plugins
class cni_plugins (
  String               $version = '1.6.2',
  Stdlib::Absolutepath $install_root = '/opt/cni',
  Stdlib::Filemode     $install_root_mode = '0755',
  String               $install_root_owner = 'root',
  String               $install_root_group = 'root',
) {
  #
  # Try not to clash with other modules which may manage this directory
  #
  ensure_resource(
    'file',
    $install_root,
    {
      ensure => directory,
      owner  => $install_root_owner,
      group  => $install_root_group,
      mode   => $install_root_mode,
    }
  )

  #
  # Create the versioned directory
  #
  file { "${install_root}/${version}":
    ensure  => directory,
    owner   => $install_root_owner,
    group   => $install_root_group,
    mode    => $install_root_mode,
    require => File[$install_root],
  }

  #
  # Get the CPU architecture, this map exists to capture edge cases and map them
  # to the appropriate architecture name to correctly construct the archive
  # file name.
  #
  $cpu_arch = $facts['os']['architecture'] ? {
    'x86_64' => 'amd64',
    'armv6'  => 'arm',
    'armv7l' => 'arm',
    'aarch64' => 'arm64',
    default   => $facts['os']['architecture'],
  }

  #
  # Fail if the given architecture is not supported by the CNI releases
  #
  $supported_arch = [
    'amd64',
    'arm',
    'arm64',
    'mips64le',
    'ppc64le',
    'riscv64',
    's390x',
  ]
  unless member($supported_arch, $cpu_arch) {
    fail("Unsupported architecture: ${cpu_arch}. Supported architectures are: ${supported_arch.join(', ')}")
  }

  #
  # Construct the archive name based on the CPU architecture and version
  #
  $archive_name = "cni-plugins-linux-${cpu_arch}-v${version}.tgz"
  $archive_url = "https://github.com/containernetworking/plugins/releases/download/v${version}/${archive_name}"

  #
  # Download and extract the CNI plugins to the specified directory
  #
  archive { $archive_name:
    path         => "/tmp/${archive_name}",
    source       => $archive_url,
    digest_url   => "${archive_url}.sha512",
    digest_type  => 'sha512',
    extract      => true,
    extract_path => "${install_root}/${version}",
    creates      => "${install_root}/${version}/dummy",
    require      => File["${install_root}/${version}"],
  }

  #
  # Create a symbolic link to the CNI plugins in the bin directory
  # This allows for easy version management.
  #
  file { "${install_root}/bin":
    ensure  => link,
    target  => "${install_root}/${version}",
    require => Archive[$archive_name],
  }
}
