# @summary Configure Globus Compute MEP
#
# Configure a Multi User Endpoint with the provided endpoint name. This
# is set up for use on a statelss node. Some assumptions may not be good
# for other node types.
#
# MEP configuration files should be available in the repos directory
# on the provisioner and tagged with the endpoint name so they can
# be located for the matching endpoint.
#
# Details derived from:
# https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html
# 
# Note: The first time you create a new enpoint, you must do so by hand.
# You will be given a link to authenticate to and receive a confirmation
# code that must be input to the 'globus-compute-endpoint enable-on-boot'
# command to coomplete the registration process and configure the systemd
# service file.
#
# Requires $endpoint_name and $endpoint_id:
# Set these in your node or role file.
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
    fail ('No globus compute endpoint name defined. Cannont continue.')
  } else {
    notify { 'endpoint_name':
      message => "Setting globus commpute endpoint name to ${endpoint_name}.",
    }
  }

  $endpoint_id = lookup('profile_globus::compute_agent::endpoint_id')
  if ( empty($endpoint_id) ) {
    fail ('No globus compute endpoint id defined. Cannont continue.')
  } else {
    notify { 'endpoint_id':
      message => "Setting globus commpute endpoint id to ${endpoint_id}.",
    }
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

  # Configure the service as a mmulti user endpoint
  exec { 'config_mep':
    command   => "globus-compute-endpoint configure --multi-user ${endpoint_name}",
    creates   => "/root/.globus_compute/${endpoint_name}",
    logoutput => true,
    require   => Package['globus-compute-agent'],
  }

  # Now get our production config files.

  if (! empty ($config_src) ) {
    # Make sure there is at least a minimum identity map file in place.
    # The cron job will update/keep this updated over time.
    #exec { 'fetch_mapfile':
    #  command   => "/usr/bin/curl --connect-timeout 10 --fail -o /root/.globus_compute/${endpoint_name}/oauth-mapfile ${config_src}/oauth-mapfile.${endpoint_name}", # lint:ignore:140chars
    #  creates   => "/usr/bin/test -f /root/.globus_compute/${endpoint_name}/oauth-mapfile",
    #  logoutput => true,
    #}
    file { 'mapfile_init':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/oauth-mapfile",
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "${config_src}/oauth-mapfile.${endpoint_name}",
    }

    ## The endpoint config file
    file { 'ep_config':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/config.yaml",
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "${config_src}/config.yaml.${endpoint_name}",
    }

    ## The user environment file
    file { 'user_environment':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/user_environment.yaml",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "${config_src}/user_environment.yaml.${endpoint_name}",
    }

    ## The user schema file
    file { 'user_schema':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/user_config_schema.json",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "${config_src}/user_config_schema.json.${endpoint_name}",
    }

    ## The user configuration template file
    file { 'user_template':
      ensure => file,
      path   => "/root/.globus_compute/${endpoint_name}/user_config_template.yaml.j2",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "${config_src}/user_config_template.yaml.j2.${endpoint_name}",
    }
  }

  ## Create systemd unit file
  exec { 'enable_systemd_unit':
    command   => "globus-compute-endpoint enable-on-boot ${endpoint_name}",
    creates   => "/etc/systemd/system/globus-compute-endpoint-${endpoint_name}.service",
    logoutput => true,
    require   => Package['globus-compute-agent'],
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
    path   => "/root/.globus_compute/storage.db",
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => "${config_src}/storage.db.${endpoint_name}",
  }
}
