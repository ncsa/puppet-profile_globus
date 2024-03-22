# @summary Install a custom GridFTP configuration
#
# Install a custom gridftp congfiguration to override certain defaults
#
# @example
#   include profile_globus::custom_gridftp
class profile_globus::custom_gridftp (
  String     $conf='/etc/gridftp.d/custom_gridftp_conf',
  Array[String] $conf_lines=[],
) {
  file { $conf:
    ensure  => file,
    content => 'control_interface 127.0.0.1',
    group   => root,
    mode    => '0644',
    owner   => root,
    notify  => Service['globus-gridftp-server'],
  }

  if ( ! empty($conf_lines) ) {
    $conf_lines.each | String $line | {
      file_line { "ensure $line in $conf":
        ensure => present,
        path   => $conf,
        line   => $line,
        match  => $line,
      }
    }
  }
}
