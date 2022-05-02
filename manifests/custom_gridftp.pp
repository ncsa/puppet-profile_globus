# @summary Install a custom GridFTP configuration
#
# Install a custom gridftp congfiguration to override certain defaults
#
# @example
#   include profile_globus::custom_gridftp
class profile_globus::custom_gridftp (
  string     $conf='/etc/gridftp.d/custom_gridftp_conf',
){ 
    file { $conf:
        content => 'control_interface 127.0.0.1',
        ensure => file,,
        group  => root,
        mode   => '0644',
        owner  => root,
    }
}
