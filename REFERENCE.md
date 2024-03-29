# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`profile_globus`](#profile_globus): initialize profile_globus
* [`profile_globus::custom_gridftp`](#profile_globus--custom_gridftp): Install a custom GridFTP configuration
* [`profile_globus::firewall`](#profile_globus--firewall): Configure firewall for Globus services
* [`profile_globus::gridmap`](#profile_globus--gridmap): configure and manage gridmap and identity mapping backend
* [`profile_globus::logging`](#profile_globus--logging): Configure logging for Globus transfer services.
* [`profile_globus::telegraf::gridftp_log_parse`](#profile_globus--telegraf--gridftp_log_parse): Ingest Globus GridFTP transfer logs via telegraf

## Classes

### <a name="profile_globus"></a>`profile_globus`

initialize profile_globus

#### Examples

##### 

```puppet
include profile_globus
```

### <a name="profile_globus--custom_gridftp"></a>`profile_globus::custom_gridftp`

Install a custom gridftp congfiguration to override certain defaults

#### Examples

##### 

```puppet
include profile_globus::custom_gridftp
```

#### Parameters

The following parameters are available in the `profile_globus::custom_gridftp` class:

* [`conf`](#-profile_globus--custom_gridftp--conf)

##### <a name="-profile_globus--custom_gridftp--conf"></a>`conf`

Data type: `String`



Default value: `'/etc/gridftp.d/custom_gridftp_conf'`

### <a name="profile_globus--firewall"></a>`profile_globus::firewall`

Configure firewall to allow Globus Services

#### Examples

##### 

```puppet
include profile_globus::firewall
```

#### Parameters

The following parameters are available in the `profile_globus::firewall` class:

* [`dports`](#-profile_globus--firewall--dports)
* [`proto`](#-profile_globus--firewall--proto)
* [`sources`](#-profile_globus--firewall--sources)

##### <a name="-profile_globus--firewall--dports"></a>`dports`

Data type: `Array[String]`

Destination ports or ranges of ports start-end required to be open for Globus services.

##### <a name="-profile_globus--firewall--proto"></a>`proto`

Data type: `String`

Protocol that needs to be open for Globus services.

##### <a name="-profile_globus--firewall--sources"></a>`sources`

Data type: `Array[String]`

CIDR sources that need to be open for Globus services.

### <a name="profile_globus--gridmap"></a>`profile_globus::gridmap`

This class will install the identity mapping backend. It will also
configu# configure the necessary scripts/cron entries to manage the gridmap
file(s).

#### Examples

##### 

```puppet
include profile_globus::gridmap
```

#### Parameters

The following parameters are available in the `profile_globus::gridmap` class:

* [`crons`](#-profile_globus--gridmap--crons)
* [`files`](#-profile_globus--gridmap--files)

##### <a name="-profile_globus--gridmap--crons"></a>`crons`

Data type: `Hash`

Cron resources for managing gridmap files

##### <a name="-profile_globus--gridmap--files"></a>`files`

Data type: `Hash`

File resources for managing gridmap files

### <a name="profile_globus--logging"></a>`profile_globus::logging`

Configure logging for Globus transfer services.

#### Examples

##### 

```puppet
include profile_globus::logging
```

#### Parameters

The following parameters are available in the `profile_globus::logging` class:

* [`gridftp_enable`](#-profile_globus--logging--gridftp_enable)
* [`gridftp_logrotate_manage`](#-profile_globus--logging--gridftp_logrotate_manage)
* [`system_tag`](#-profile_globus--logging--system_tag)

##### <a name="-profile_globus--logging--gridftp_enable"></a>`gridftp_enable`

Data type: `Boolean`

Should GridFTP logging be gathered by rsyslog? Defaults
to true.

NOTE: Amazon S3 (and possibly other Globus transfer plug-ins)
also uses this log.

##### <a name="-profile_globus--logging--gridftp_logrotate_manage"></a>`gridftp_logrotate_manage`

Data type: `Boolean`

Should this module manage logrotate config for the GridFTP log?
The main goal is to notify rsyslog when the GridFTP log rotates.

##### <a name="-profile_globus--logging--system_tag"></a>`system_tag`

Data type: `Optional[String]`

System name/designation to be included in log message tags.

### <a name="profile_globus--telegraf--gridftp_log_parse"></a>`profile_globus::telegraf::gridftp_log_parse`

See https://git.ncsa.illinois.edu/ici-monitoring/ici-developed-checks/-/tree/master/globus

#### Examples

##### 

```puppet
include profile_globus::telegraf::gridftp_log_parse
```

#### Parameters

The following parameters are available in the `profile_globus::telegraf::gridftp_log_parse` class:

* [`enabled`](#-profile_globus--telegraf--gridftp_log_parse--enabled)
* [`required_pkgs`](#-profile_globus--telegraf--gridftp_log_parse--required_pkgs)
* [`script_cfg`](#-profile_globus--telegraf--gridftp_log_parse--script_cfg)
* [`telegraf_cfg`](#-profile_globus--telegraf--gridftp_log_parse--telegraf_cfg)

##### <a name="-profile_globus--telegraf--gridftp_log_parse--enabled"></a>`enabled`

Data type: `Boolean`

Enable or disable this health check

##### <a name="-profile_globus--telegraf--gridftp_log_parse--required_pkgs"></a>`required_pkgs`

Data type: `Array[String]`

List of required packages for this telegraf check

##### <a name="-profile_globus--telegraf--gridftp_log_parse--script_cfg"></a>`script_cfg`

Data type: `Hash`

Hash that controls the values for the script config file.

Hash expects a value for these keys:

```
log_file_path: "/path/to/log_file"  # Defaults to: /var/log/gridftp.log
endpoint: "name_of_globus_endpoint" # No default, required for log collecting to work
default_lat: "gps_lat_coordinate"   # Will default to NCSA if not given
default_long: "gps_long_coordinate" # Will default to NCSA if not given
```

##### <a name="-profile_globus--telegraf--gridftp_log_parse--telegraf_cfg"></a>`telegraf_cfg`

Data type: `Hash`

Hash of key:value pairs passed to telegraf::input as options

