# @summary Configure Globus Compute MEP
#
# Configure a Multi User Endpoint with the provided endpoint name. This
# is set up for use on a stateless node. Some assumptions may not be good
# for other node types.
#
# MEP configuration files should either be already installed (for
# a stateful server) or at a location accessible using Puppet's
# file resource. $cfg_src can be any valid "source" that the file
# resource understands (eg file, puppet, etc.).
#
# Details derived from:
# https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html
#
# Note: The first time you create a new endpoint, you must do so by hand.
# You will be given a link to authenticate to and receive a confirmation
# code that must be input to the 'globus-compute-endpoint enable-on-boot'
# command to complete the registration process and configure the systemd
# service file.
#
# Requires $endpoint_name and $endpoint_id:
# Set these in your nodes or role file.
#
# For identity mapping we also require a script for
# looking up identities in our controlled map file.
# -- this should be fixed to allow other lookup options -- JAG
#
# $identity_mapfile is the path to the file containing
# containing user identity associations
#
# @example
# include profile_globus::compute_agent::config_mep
#
class profile_globus::compute_agent::config_mep {
  Exec {
    path => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
  }

  # Lookup our required endpoint information
  $endpoint_name = lookup('profile_globus::compute_agent::endpoint_name')
  if ( empty($endpoint_name) ) {
    fail ('No globus compute endpoint name defined. Cannot continue.')
  } else {
    notify { 'endpoint_name':
      message => "Setting globus compute endpoint name to ${endpoint_name}.",
    }
  }

  $endpoint_id = lookup('profile_globus::compute_agent::endpoint_id')
  if ( empty($endpoint_id) ) {
    fail ('No globus compute endpoint id defined. Cannot continue.')
  } else {
    notify { 'endpoint_id':
      message => "Setting globus compute endpoint id to ${endpoint_id}.",
    }
  }

  # Get the path to our idenity map file for this resource
  $identity_mapfile = lookup('profile_globus::compute_agent::identity_mapfile')
  if ( empty($identity_mapfile) ) {
    fail ('No user identity map file defined. Cannot continue.')
  }

  # Lookup the source for our desired config files. If a value
  # is not set. No config files will be copied into the endpoint
  # directory.
  $config_src = lookup('profile_globus::compute_agent::conf_file_src')
  if ( empty($config_src) ) {
    notify { 'missing_config':
      message => 'No source for endpoint config files was specified. None will be imported.',
    }
  }

  # Now get our production config files.

  if (! empty ($config_src) ) {
    # Make sure the install directory exists
    file { 'install_dir':
      ensure  => directory,
      path    => '/root/.globus_compute/',
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      require => Package['globus-compute-agent'],
    }

    file { 'endpoint_dir':
      ensure => directory,
      path   => "/root/.globus_compute/${endpoint_name}",
      owner  => 'root',
      group  => 'root',
      mode   => '0744',
    }

    file { 'idmap_dir':
      ensure => directory,
      path   => "/etc/globus/",
      owner  => 'root',
      group  => 'root',
      mode   => '0744',
    }

    # Make sure there is at least a minimum identity map file in place.
    # This location is hard-coded in the mapapp.py script...
    # Puppet will keep the destination file in sync with the
    # source file. You may need to adjust the puppet agent execution
    # interval depending on how frequently you would like to have this
    # sync'd.
    file { 'identity_mapfile':
      ensure => file,
      path   => "/etc/globus/oauth-mapfile",
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => $identity_mapfile,
    }

    ## The identity mapping config
    file { 'mapping_config':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/identity_mapping_config.json",
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "${config_src}/endpoints/${endpoint_name}/identity_mapping_config.json",
    }

    ## The endpoint config file
    file { 'ep_config':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/config.yaml",
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "${config_src}/endpoints/${endpoint_name}/config.yaml",
    }

    ## The user environment file
    file { 'user_environment':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/user_environment.yaml",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "${config_src}/endpoints/${endpoint_name}/user_environment.yaml",
    }

    ## The user schema file
    file { 'user_schema':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/user_config_schema.json",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "${config_src}/endpoints/${endpoint_name}/user_config_schema.json",
    }

    ## The user configuration template file
    file { 'user_template':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/user_config_template.yaml.j2",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "${config_src}/endpoints/${endpoint_name}/user_config_template.yaml.j2",
    }

    ## Restore the endpoint id file
    file { 'endpoint_id':
      ensure  => file,
      path    => "/root/.globus_compute/${endpoint_name}/endpoint.json",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => "{\"endpoint_id\": \"${endpoint_id}\"}",
    }

    ## Restore the local database file containing the endpoint/application access tokens
    ## Note: this is not endpoint specific but we will treat it that way until there is
    ## a demonstrated use case for multiple endpoints on one server.
    file { 'storage.db':
      ensure => file,
      path   => '/root/.globus_compute/storage.db',
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "${config_src}/endpoints/${endpoint_name}/storage.db",
    }
  }

  # Install the id mapping script
  file { 'mapapp_script':
    ensure => file,
    path   => '/root/.globus_compute/user_identity_mapper',
    group  => 'root',
    mode   => '0755',
    owner  => 'root',
    source => 'puppet:///modules/profile_globus/mapapp.py',
  }

# Setup an rsyslog rule to get the agent log messages into the log stream
file { 'agentlog-to-rsyslog':
  ensure  => file,
  path    => "/etc/rsyslog.d/60_globus_compute.conf",
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  notify  => Service['rsyslog'],
  content => @(EOT)
# We need the imfile module
module(load="imfile" PollingInterval="5")

# Our endpoint log file
input(type="imfile"
  File="/root/.globus_compute/${endpoint_name}/endpoint.log"
  Tag="GCA:"
  PersistStateInterval="0"
  reopenOnTruncate="on"
  discardTruncatedMsg="on"
  msgDiscardingError="on"
)
EOT,
  }
}
