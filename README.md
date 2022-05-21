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

## Usage

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

