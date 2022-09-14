# @summary configure and manage gridmap and identity mapping backend
#
# This class will install the identity mapping backend. It will also
# configu# configure the necessary scripts/cron entries to manage the gridmap
# file(s).
#
# @param crons
#   Cron resources for managing gridmap files
#
# @param files
#   File resources for managing gridmap files
#
# @example
#   include profile_globus::gridmap
class profile_globus::gridmap (
    Hash $crons,
    Hash $files,
) {

    $cron_defaults = {
        ensure => present,
    }
    ensure_resources('cron', $crons, $cron_defaults )

    $file_defaults = {
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }
    ensure_resources('file', $files, $file_defaults )

    # install identity mapping script
    file { '/opt/globus_map':
        ensure => directory,
        group  => 'root',
        mode   => '0755',
        owner  => 'root',
    }

    file { '/opt/globus_map/mapapp.py':
        ensure => present,
        group  => 'root',
        mode   => '0755',
        owner  => 'root',
        source => 'puppet:///modules/profile_globus/mapapp.py',
    }

}
