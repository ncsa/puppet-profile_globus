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
  # Lookup our required endpoint information
  $endpoint_name = lookup('profile_globus::compute_agent::endpoint_name')
  if ( empty($endpoint_name) ) {
    fail ('No globus compute endpoint name defined. Cannont continue.')
  } else {
    notice ("Setting globus commpute endpoint name to ${endpoint_name}")
  }
  # Start/restart the endpoint service
  exec { 'start_mep':
    command   => "systemctl enable globus-compute-endpoint-${endpoint_name} --now",
    unless    => "systemctl --no-pager status globus-compute-endpoint-${endpoint_name}",
    logoutput => 'on_failure',
  }
}
