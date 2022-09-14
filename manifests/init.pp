# @summary initialize profile_globus
#
# @example
#   include profile_globus
class profile_globus {

  include ::gcsv5
  include ::profile_globus::custom_gridftp
  include ::profile_globus::firewall
  include ::profile_globus::telegraf::gridftp_log_parse
  include ::profile_globus::gridmap
}
