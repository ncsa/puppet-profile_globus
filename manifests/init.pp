# @summary initialize profile_globus
#
# @example
#   include profile_globus
class profile_globus {

  include ::profile_globus::firewall
  include ::gcsv5
  include ::profile_globus::custom_gridftp
}
