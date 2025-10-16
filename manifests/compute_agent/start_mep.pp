# @summary Start a configured Globus Compute MEP
#
# Start the MEP service with the configured endpoint name
#
# Details derived from:
# https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html
#
# Requires  $endpoint_name:
# The name given to the endpoint configuration. Set this in
# your node or role file.
# 
#
# @example
#  include profile_globus::compute_agent::config_mep
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

  ## Restore systemd unit file (for stateless servers) and start
  ## the endpoint service
  systemd::unit_file { 'mep.service':
    source => "${config_src}/endpoints/${endpoint_name}/globus-compute-endpoint-${endpoint_name}.service",
    enable => true,
    active => true,
  }
}
