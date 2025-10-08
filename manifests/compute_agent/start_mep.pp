# @summary Start a configured Globus Compute MEP
#
# Start the MEP service with the configured endpoint name
#
# Details derived from:
# https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html
#
# @param $endpoint_name
# 
#
# @example
#  include profile_globus::compute_agent::config_mep
class profile_globus::compute_agent::start_mep (
  String $endpoint_name,
)
{
  # Start/restart the endpoint service
  exec { 'start_mep':
    command => "systemctl enable globus-compute-endpoint-${endpoint_name} --now",
    unless => "systemctl --no-pager status globus-compute-endpoint-${endpoint_name}",
    logoutput => 'on_failure',
  }
}
