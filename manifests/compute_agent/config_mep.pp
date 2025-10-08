# @summary Configure Globus Compute MEP
#
# Configure a Multi User Endpoint with the provided endpoint name.
# MEP configuration files should be available in the repos directory
# on the provisioner and tagged with the endpoint name so they can
# be located for the matching endpoint.
#
# Details derived from:
# https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html
#
# @param $endpoint_name
# 
#
# @example
#  include profile_globus::compute_agent::config_mep
class profile_globus::compute_agent::config_mep (
  String $endpoint_name,
)
{
  # Configure the service as a mmulti user endpoint
  exec { 'config_mep':
    command => "globus-compute-endpoint configure --multi-user ${endpoint_name}",
    creates => "/root/.globus_compute/${endpoint_name}",
    logoutput => 'true',
    require => Package['globus-compute-agent'],
  }

  # Now get our production config files. # These need to exist in the xcat repo on the provisioner.

  # Make sure there is at least a minimum identity map file in place.
  # The cron job will update/keep this updated over time.
  exec { 'fetch_mapfile':
    command => "curl --connect-timeout 10 --fail -o /root/.globus_compute/${endpoint_name}/oauth_mapfile http://172.28.22.19/install/repos/Globus-Compute-Agent/oauth_mapfile.${endpoint_name}",
    creates => "test -f /root/.globus_compute/${endpoint_name}/oauth_mapfile",
    logoutput => 'true',
  }
  
  ## The endpoint config file
  file { 'ep_config':
    path   => "/root/.globus_compute/${endpoint_name}/config.yaml"
    ensure => file,
    group  => 'root',
    mode   => '0600',
    owner  => 'root',
    source => "http://172.28.22.19/install/repos/Globus-Compute-Agent/config.yaml.${endpoint_name}",
  }

  ## The user environement file
  file { 'user_environment':
    path   => "/root/.globus_compute/${endpoint_name}/user_environment.yaml"
    ensure => file,
    group  => 'root',
    mode   => '0644',
    owner  => 'root',
    source => "http://172.28.22.19/install/repos/Globus-Compute-Agent/user_environment.yaml.${endpoint_name}",
  }

  ## The user schema file
  file { 'user_schema':
    path   => "/root/.globus_compute/${endpoint_name}/user_config_schema.json"
    ensure => file,
    group  => 'root',
    mode   => '0644',
    owner  => 'root',
    source => "http://172.28.22.19/install/repos/Globus-Compute-Agent/user_config_schema.json.${endpoint_name}",
  }
  
  ## The user configuration template file
  file { 'user_schema':
    path   => "/root/.globus_compute/${endpoint_name}/user_config_template.yaml.j2"
    ensure => file,
    group  => 'root',
    mode   => '0644',
    owner  => 'root',
    source => "http://172.28.22.19/install/repos/Globus-Compute-Agent/user_config_template.yaml.j2.${endpoint_name}",
  }
}
