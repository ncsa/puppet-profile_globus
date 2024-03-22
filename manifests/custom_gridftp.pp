# @summary Install a custom GridFTP configuration
#
# Install a custom gridftp congfiguration to override certain defaults
#
# @example
#   include profile_globus::custom_gridftp
class profile_globus::custom_gridftp (
  String     $conf='/etc/gridftp.d/custom_gridftp_conf',
  Hash       $conf_lines,
) {
  file { $conf:
    ensure  => file,
    group   => root,
    mode    => '0644',
    owner   => root,
    notify  => Service['globus-gridftp-server'],
  }

  if ( ! empty($conf_lines) ) {
    $conf_lines.each | String $key, String $value | {
      file_line { "ensure $line in $conf":
        ensure => present,
        path   => $conf,
        line   => "$key $value",
        match  => $key,
        notify => Service['globus-gridftp-server'],
      }
    }
  }
}
