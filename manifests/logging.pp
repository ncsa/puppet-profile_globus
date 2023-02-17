# @summary Configure logging for Globus transfer services.
#
# Configure logging for Globus transfer services.
#
# @param gridftp_enable
#   Should GridFTP logging be gathered by rsyslog? Defaults
#   to true.
#
#   NOTE: Amazon S3 (and possibly other Globus transfer plug-ins)
#   also uses this log.
#
# @param gridftp_logrotate_manage
#   Should this module manage logrotate config for the GridFTP log?
#   The main goal is to notify rsyslog when the GridFTP log rotates.
#
# @param system_tag
#   System name/designation to be included in log message tags.
#
# @example
#   include profile_globus::logging
class profile_globus::logging (
  Boolean          $gridftp_enable,
  Boolean          $gridftp_logrotate_manage,
  Optional[String] $system_tag,
) {
  # defaults for file resources
  File {
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

  if $gridftp_enable {
    # determine the tag that should be added to log messages
    # going into rsyslog
    if $system_tag {
      $message_tag = "gridftp_${system_tag}:"
    } else {
      $message_tag = 'gridftp:'
    }

    # rsyslog GridFTP logging config
    file { '/etc/rsyslog.d/gridftp.conf':
      content => epp('profile_globus/rsyslog.gridftp.conf.epp'),
      notify  => Service['rsyslog'],
    }

    # manage logrotate config related to GridFTP
    if $gridftp_logrotate_manage {
      $gridftp_logrotate_require_package = $gcsv5::package_name
      File_line {
        path    => '/etc/logrotate.d/globus-connect-server',
        replace => false,
        require => "Package[${gridftp_logrotate_require_package}]",
      }

      file_line { 'gridftp_logrotate_postrotate':
        after => '^\/var\/log\/gridftp\.log \{',
        line  => '  postrotate',
        match => '^  postrotate$',
      }
      file_line { 'gridftp_logrotate_hup_rsyslog':
        after => '^  postrotate$',
        line  => '    /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true',
        match => 'systemctl kill.*rsyslog\.service.*true$',
      }
      file_line { 'gridftp_logrotate_endscript':
        after => '^    \/usr\/bin\/systemctl kill \-s HUP rsyslog\.service.*true$',
        line  => '  endscript',
        match => '^  endscript$',
      }
    }
  }
}
