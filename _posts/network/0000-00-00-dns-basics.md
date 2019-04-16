---
date: 2019-04-02
title: Network, DNS overview 101
categories: [cs_related, network]
---

## Common resources records (aka RR)

* `A` :  IPv4 addresses
* `AAAA` : IPv6 addresses
* `CNAME` : Canonical name that should be used for the lookup
* `SOA` : Start of authority, indicates the domain zone owned by the name server
* `NS` : Fqdn of the authoritave server for a given zone
* `MX` : Mail server fqdn
* `TXT` : A list of key-value pairs with a specific semantic each (originally designed for comments).
  * Used to prove ownership of a domain by tagging a TXT with s site verification code provided by google/facebook
* `PTR` : Host FQDN used in reverse lookups

## DNS lookups

The host resolution can be **iterative** (the client contacts each autoritative DNS down the tree) or **recursive** (the DNS server contacted by the client does the resolution on his behalf).

![Network_VLAN.svg]({{ site.images }}/Network_DNS_101.svg){:.my-inline-img}

The registrars also maintain a WHOIS database that can be queried by fqdn, IP and AS.

![Network_WHOIS_query.svg]({{ site.images }}/Network_WHOIS_query.svg){:.my-inline-img}

### Reverse lookup

Done by doing a name lookup on a hostname derived from the ip address.
* IPv4 : `123.456.789.0` => `0.789.456.123.in-addr.arpa`
* IPv6 : `dead:2::beef` => `f.e.e.b.0[20 times].2.0.0.0.d.a.e.d.ip6.arpa`

### Try it

* `dig docs.google.com -t ANY +trace`
* `dig 6.3.7.8.0.0.0.0.0.0.0.0.0.0.0.0.3.0.0.0.8.7.5.0.1.0.a.2.ip6.arpa -t PTR`
* `whois google.com|AS15169|172.217.18.110`

## Interpreting a zone file

A DNS zone is a subtree of the domain hierarchy handled  by a single organisation.

{:.my-table}
| subject | Valid for X secs | Type (always internet) | RR type | extra |
|---------|------------------|------------------------|---------|-------|
| netflix.com | 600 | IN | SOA  | ns-81.awsdns-10.com. `<admin mail> <zone refresh in secs> ...` |
| netflix.com | 59  | IN | NS   | ns-81.awsdns-10.com. |
| netflix.com | 299 | IN | NS   | ns-66.awsdns-10.com. |
| netflix.com | 299 | IN | NS   | ns-66.awsdns-10.com. |
| netflix.com | 59  | IN | TXT  | facebook-domain-verification=YYY |
| netflix.com | 59  | IN | TXT  | google-site-verification=XXX |
| netflix.com | 59  | IN | A    | 123.123.123.123 |
| netflix.com | 59  | IN | A    | 123.123.123.122 |
| netflix.com | 59  | IN | AAAA | dead::beef |

## DNSSEC

Note that DNS normally **runs over UDP unencrypted** even if a man-in-the-middle attack cannot forge records protected by signature, it can see the DNS trafic.
DNS over HTTPS seems like a more secure alternative.

### Extra resource records

* `RRSIG` : The signature for the set of RR of a given type
* `DS` : 
* `DNSKEY` : The public key used to sign
* `NSEC3` : Involved mechanism to proove the non existence of a fqdn in the zone

![Network_DNSSEC.svg]({{ site.images }}/Network_DNSSEC.svg){:.my-inline-img}

Note on the sequence diagram below that **any dns server** can provide authenticated records for a zone it does not own.

![Network_DNSSEC_seq.svg]({{ site.images }}/Network_DNSSEC_seq.svg){:.my-inline-img}

Note that NSEC3 does not mention domain names but hashes to avoid domain enumeration.

