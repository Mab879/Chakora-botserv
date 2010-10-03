# operserv/dns by Russell Bradford. Adds DNS to OperServ, which allows users with OperServ Access to lookup an IPv4 Address for any hostname specified.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;
use Net::DNS;

module_init("operserv/dns", "Russell Bradford", "1.0", \&init_os_dns, \&void_os_dns, "all");

sub init_os_dns {
	cmd_add("operserv/dns", "Perform a DNS Query on a Hostname", "Perform a DNS Query on a hostname and \nget its IPv4 Address or Addresses \nAlternatively you can lookup a nameserver address or addresses from a domain name \n[T]\nSyntax: DNS [hostname/domain] [A/NS]", \&svs_os_dns);
}

sub void_os_dns {
	eval {
    		require Net::DNS;
    		1;
	     } or svsflog("modules", "Unable to load operserv/dns, Net::DNS not installed.") and module_void("operserv/dns");

	delete_sub 'init_os_dns';
	delete_sub 'svs_os_dns';
	cmd_del("operserv/dns");
        delete_sub 'void_os_dns';
}

sub svs_os_dns {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("operserv", $user, "Not enough parameters. Syntax: DNS [hostname/domain] [A/NS/MX]");
		return;
	}

	if (!defined($sargv[2])) {
		serv_notice("operserv", $user, "Not enough parameters. Syntax: DNS [hostname/domain] [A/NS/MX]");
		return;
	}
	
	if (lc($sargv[2]) eq "a") {
  		my $res = new Net::DNS::Resolver;
  		my $query = $res->search($sargv[1], "A");
		my $rr;

  		if ($query) {
			serv_notice("operserv", $user, "\002 ** IPv4 Addresses Found ** \002");
			serv_notice("operserv", $user, "Hostname: ".$sargv[1]);
      			foreach $rr ($query->answer) {
          			next unless $rr->type eq "A";
				serv_notice("operserv", $user, ">> ".$rr->address);
      			}
			serv_notice("operserv", $user, "\002 ************************** \002");
			svsilog("operserv", $user, "DNS", $sargv[1]." (Type: ".$sargv[2].")");
			svsflog('commands', uidInfo($user, 1).": OperServ: DNS: $sargv[1] (Type: $sargv[2])");
			return;
  		}
  		else {
			svsilog("operserv", $user, "DNS:FAIL:QUERY", $sargv[1], $sargv[2], $res->errorstring);
			svsflog('commands', uidInfo($user, 1).": OperServ: DNS:FAIL:QUERY: $sargv[1] TYPE $sargv[2] ($res->errorstring)");
			serv_notice("operserv", $user, "DNS Query Failed: ", $res->errorstring);
			return;
  		}

	}
	elsif (lc($sargv[2]) eq "ns") {
  		my $res = new Net::DNS::Resolver;
  		my $query = $res->query($sargv[1], "NS");
		my $rr;

  		if ($query) {
			serv_notice("operserv", $user, "\002 **   NameServer Found   ** \002");
			serv_notice("operserv", $user, "Hostname: ".$sargv[1]);
      			foreach $rr ($query->answer) {
          			next unless $rr->type eq "NS";
				serv_notice("operserv", $user, ">> ".$rr->nsdname);
      			}
			serv_notice("operserv", $user, "\002 ************************** \002");
			svsilog("operserv", $user, "DNS", $sargv[1]." (Type: ".$sargv[2].")");
			svsflog('commands', uidInfo($user, 1).": OperServ: DNS: $sargv[1] (Type: $sargv[2])");
			return;
  		}
  		else {
			svsilog("operserv", $user, "DNS:FAIL:QUERY", $sargv[1], $sargv[2], $res->errorstring);
			svsflog('commands', uidInfo($user, 1).": OperServ: DNS:FAIL:QUERY: $sargv[1] TYPE $sargv[2] ($res->errorstring)");
			serv_notice("operserv", $user, "DNS Query Failed: ", $res->errorstring);
			return;
  		}

	}
	elsif (lc($sargv[2]) eq "mx") {
  		my $res = new Net::DNS::Resolver;
		my $rr;
		my @mx;

 		@mx = mx($res, $sargv[1]);
  		if (@mx) {
			serv_notice("operserv", $user, "\002 **  Mail Servers Found  ** \002");
			serv_notice("operserv", $user, "Hostname: ".$sargv[1]);
      			foreach $rr (@mx) {
				serv_notice("operserv", $user, ">> ".$rr->preference." - ".$rr->exchange);
      			}
			serv_notice("operserv", $user, "\002 ************************** \002");
			svsilog("operserv", $user, "DNS", $sargv[1]." (Type: ".$sargv[2].")");
			svsflog('commands', uidInfo($user, 1).": OperServ: DNS: $sargv[1] (Type: $sargv[2])");
  		}
  		else {
			svsilog("operserv", $user, "DNS:FAIL:QUERY", $sargv[1], $sargv[2], $res->errorstring);
			svsflog('commands', uidInfo($user, 1).": OperServ: DNS:FAIL:QUERY: $sargv[1] TYPE $sargv[2] ($res->errorstring)");
			serv_notice("operserv", $user, "MX Lookup Failed: ", $res->errorstring);
			return;
  		}

	}
	else
	{
		serv_notice("operserv", $user, "Invalid Record Type. Syntax: DNS [hostname/domain] [A/NS/MX]");
		return;
	}
}

1;