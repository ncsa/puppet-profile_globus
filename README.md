# profile_globus

![pdk-validate](https://github.com/ncsa/puppet-profile_globus/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_globus/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - Install and configure Globus Connect Server v5

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile customizes a host to install and configure Globus Connect Server v5


## Setup

```
include ::profile_globus
```

See also hiera values that need setting in https://github.com/srstevens/puppet-gcsv5

Additions for Globus Compute Multi-User Endpoints:
Two new functions have been added to configure and start the compute agent on a server.
- profile_globus::config_mep
- profile_globus::start_mep

The config_mep function allows for custom endpoint configuration files to be provisioned and the start_mep function can be used to configure the systemd service and start the endpoint agent on a configured system. These functions make use of the profile_globus functions to install the Globus Connect software packages and configure firewall rules. The compute endpoints use a different means of managing the user identity map files and these should be overriden in your compute agent role/nodes manifiests. See the globus_compute role and dt-glbscmp01 nodes definition for examples (https://git.ncsa.illinois.edu/ici/asd/delta-control) 

At a minimum these variables need defined for proper function (example values from Delta included for illustration):
```
profile_globus::compute_agent::cluster_name: "delta"
profile_globus::compute_agent::endpoint_name: "delta_test"
profile_globus::compute_agent::endpoint_id: "44a4297d-d07d-41a8-8ce9-c89464b23330"
profile_globus::compute_agent::conf_file_src: "http://172.28.22.19/install/repos/Globus-Compute-Agent"
profile_globus::compute_agent::identity_mapfile: "/sw/admin/grid-security/oauth-mapfile.delta"
```
A Multi-User Endpoint must first be intialized as described in https://globus-compute.readthedocs.io/en/stable/endpoints/multi_user.html. The configuration files/information created by this process must be captured and placed in a location defined in ``compute_agent::conf_file_src``. See the config_mep.pp file for a list of those details. If your node is stateful, leaving this blank will cause the loading of the config files to be skipped.

## Usage

### Log collection

Anything that logs to /var/log/gridftp.log will be collected by rsyslog by default. Rsyslog collection of any other custom logs
is not yet supported.

### Telegraf

For collecting GridFTP transfer log data via telegraf, you must set at a minimum:
```yaml
profile_globus::telegraf::gridftp_log_parse::script_cfg:
  endpoint: "iccp"  # Name of globus endpoint ex: iccp
```

To disable telegraf collecting of transfer logs:
```yaml
profile_globus::telegraf::gridftp_log_parse::enabled: false
```


## Dependencies

* https://github.com/srstevens/puppet-gcsv5
* https://github.com/ncsa/puppet-telegraf
* https://github.com/ncsa/puppet-profile_monitoring


## Reference

See: [REFERENCE.md](REFERENCE.md)

