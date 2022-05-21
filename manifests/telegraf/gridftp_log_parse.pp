# @summary Ingest Globus GridFTP transfer logs via telegraf
#
# See https://git.ncsa.illinois.edu/ici-monitoring/ici-developed-checks/-/tree/master/globus
#
# @param enabled
#   Enable or disable this health check
#
# @param required_pip3_pkgs
#   List of required pip3 packages for this telegraf check
#
# @param required_pkgs
#   List of required packages for this telegraf check
#
# @param script_cfg
#   Hash that controls the values for the script config file.
#
#   Hash expects a value for these keys:
#
#   ```
#   log_file_path: "/path/to/log_file"  # Defaults to: /var/log/gridftp.log
#   endpoint: "name_of_globus_endpoint" # No default, required for log collecting to work
#   ```
#
# @param telegraf_cfg
#   Hash of key:value pairs passed to telegraf::input as options
#
# @example
#   include profile_globus::telegraf::gridftp_log_parse
class profile_globus::telegraf::gridftp_log_parse (
  Boolean         $enabled,
  Array[ String ] $required_pip3_pkgs,
  Array[ String ] $required_pkgs,
  Hash            $script_cfg,
  Hash            $telegraf_cfg,
){

  #
  # Requirements specific for this check
  #
  ensure_packages($required_pkgs)
  ensure_packages($required_pip3_pkgs, { provider => 'pip3' })

  if ( empty($script_cfg['endpoint'])) {
    notify {'profile_globus::telegraf::gridftp_log_parse::script_cfg missing value for endpoint':}
  }

  #
  # Templatized telegraf script with config
  #
  $script_base_name = 'gridftp_log_parse'
  $script_path = '/etc/telegraf/scripts/globus'
  $script_extension = '.sh'
  $script_full_path = "${script_path}/${script_base_name}${script_extension}"
  $script_cfg_full_path = "${script_path}/${script_base_name}_config"

  include profile_monitoring::telegraf
  include ::telegraf

  if ($enabled) and ($::profile_monitoring::telegraf::enabled) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  # Create folder for telegraf scripts
  $script_dir_defaults = {
    ensure => 'directory',
    owner  => 'root',
    group  => 'telegraf',
    mode   => '0750',
  }
  ensure_resource('file', $script_path , $script_dir_defaults)

  # Setup telegraf config
  $telegraf_cfg_final = $telegraf_cfg + { 'command' => $script_full_path }
  telegraf::input { $script_base_name :
    ensure      => $ensure_parm,
    plugin_type => 'exec',
    options     => [ $telegraf_cfg_final ],
    require     => File[$script_full_path],
  }

  # Setup the actual script
  $script_defaults = { source_path => $script_cfg_full_path,  }
  file { $script_full_path :
    ensure  => $ensure_parm,
    content => epp("${module_name}/${script_base_name}${script_extension}.epp", $script_defaults),
    mode    => '0750',
    owner   => 'root',
    group   => 'telegraf',
  }

  # Setup the scripts config file
  file { $script_cfg_full_path :
    ensure  => $ensure_parm,
    content => epp("${module_name}/${script_base_name}_config.epp", $script_cfg),
    owner   => 'root',
    group   => 'telegraf',
    mode    => '0740',
  }

  #
  # Extra files needed for this telegraf check
  #

  # Setup mmdb file
  file { "${script_path}/GeoLite2-City.mmdb" :
    ensure  => $ensure_parm,
    content => file("${module_name}/GeoLite2-City.mmdb"),
    owner   => 'root',
    group   => 'telegraf',
    mode    => '0750',
  }

  # Setup python helper script
  file { "${script_path}/ip2geohash.py" :
    ensure  => $ensure_parm,
    content => file("${module_name}/ip2geohash.py"),
    owner   => 'root',
    group   => 'telegraf',
    mode    => '0750',
  }

}
