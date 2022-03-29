# @summary Configure firewall for Globus services
#
# Configure firewall to allow Globus Services
#
# @param dports
#   Destination ports required to be open for Globus services.
#
# @param proto
#   Protocol that needs to be open for Globus services.
#
# @param sources
#   CIDR sources that need to be open for Globus services.
#
# @example
#   include profile_globus::firewall
class profile_globus::firewall (
  Array[Integer]  $dports,
  String          $proto,
  Array[String]   $sources,
) {

  $sources.each | $location, $source |
  {
    firewall { "200 allow Lustre via ${proto} from ${source}":
      proto  => $proto,
      dport  => $dports,
      source => $source,
      action => 'accept',
    }
  }
}
