# cni_plugins

This module provides a simple way to install and update the CNI plugins from the
Cloud Native Computing Foundation.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with cni_plugins](#setup)
    * [What cni_plugins affects](#what-cni_plugins-affects)
    * [Beginning with cni_plugins](#beginning-with-cni_plugins)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will allow you to install and update the CNI plugins from CNCF. It
maintains versions in a way that will allow for easy roll-back.

## Setup

### What cni_plugins affects

This module creates and manages the directory where the plugins are installed.
By default this is `/opt/cni`. It also manages the `bin/` directory, as a
symlink, inside of the main directory. The CNI plugins are extracted to a 
versioned directory inside the main directory. The `bin` directory is then
linked to the specified version.

By default this looks like this

```bash
/opt/cni       # Install root, managed by module
/opt/cni/1.6.2 # Versioned directory where bins are stored
/opt/cni/bin   # Symlink to specified version
```

### Beginning with cni_plugins

The most basic usage of this module would look like below

```puppet
class { 'cni_plugins': }
```

## Usage

Some more complex use-cases could look like the following

### Use a specific version of the CNI plugins
```puppet
class { 'cni_plugins':
  version => '1.2.0,
}
```

### Install in a non-default place
```puppet
class { 'cni_plugins':
  install_root => '/var/lib/cni',
}
```

### Change the owner of the directory
```puppet
class { 'cni_plugins':
  owner => 'nobody',
  group => 'nobody',
}
```

## Limitations

This module could cause other modules to install binaries in the cni bin
directory when upgrading versions. This is because the symlink is changed to a
new directory where the existing binary won't be installed.

This module also does not support proxies nor does it allow for changing the
URL where the packages could be downloaded. I will gladly accept PRs that solve
either or both of these limitations.

## Development

PRs are welcome for this project. They must be accompanied by an issue
describing the problem they are solving. __All__ code must also pass and include
unit tests and/or acceptance tests.

Any code contributed to this project must follow PDK coding conventions.

```shell
#
# Basic validations
#
pdk validate
pdk test unit --parallel

#
# Acceptance (litmus) testing, requires docker
#
pdk bundle exec rake 'litmus:provision_list[default]'
pdk bundle exec rake 'litmus:install_agent'
pdk bundle exec rake 'litmus:install_module'
pdk bundle exec rake 'litmus:acceptance:parallel'
pdk bundle exec rake 'litmus:tear_down'
```
