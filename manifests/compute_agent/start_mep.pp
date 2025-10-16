# @summary Start a configured Globus Compute MEP
#
# Create the systemd unit file and start the named
# endpoint service. Only configured for stateless
# nodes. Will need some alterations to work better
# on stateful nodes (not requiring a remote unit file).
#
# Details derived from:
# https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html
#
# Requires $endpoint_name:
# The name given to the endpoint configuration. Set this in
# your node or role file.
#
# Requires $config_src:
# The location of the file repo to locate the unit file.
#
# @example
#  include profile_globus::compute_agent::start_mep
#
class profile_globus::compute_agent::start_mep {
  Exec {
    path => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
  }

  # Lookup our required endpoint information
  $endpoint_name = lookup('profile_globus::compute_agent::endpoint_name')
  if ( empty($endpoint_name) ) {
    fail ('No globus compute endpoint name defined. Cannont continue.')
  } else {
    notify { 'start_endpoint':
      message => "Starting globus compute endpoint named ${endpoint_name}",
    }
  }
  
  # Lookup the source for the service unit file.
  $config_src = lookup('profile_globus::compute_agent::conf_file_src')

  # Set the service name
  $service_name = "globus-compute-endpoint-${endpoint_name}.service"

  ## Restore systemd unit file (for stateless servers) and start
  ## the endpoint service
  systemd::unit_file { $service_name:
    ensure => present,
    source => "${config_src}/endpoints/${endpoint_name}/globus-compute-endpoint-${endpoint_name}.service",
    enable => true,
    active => true,
  }
}
