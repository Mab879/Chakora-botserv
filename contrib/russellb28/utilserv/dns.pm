# utilserv/dns by Russell Bradford. Adds DNS to UtilServ, which allows users to lookup an IPv4 Address for any hostname specified.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("utilserv/dns", "Russell Bradford", "1.0", \&init_us_dns, \&void_us_dns, "all");

sub init_us_dns {
	if(!eval { require Net::DNS; 1; })
	{
		svsflog("modules", "Unable to load utilserv/dns, Net::DNS not installed.");
		if ($Chakora::synced) { logchan("operserv", "\002utilserv/dns\002: Unable to load, Net::DNS not installed."); }
		module_void("utilserv/dns");
		return 0;
	}
	cmd_add("utilserv/dns", "Perform a DNS Query on a Hostname", "Perform a DNS Query on a hostname and \nget its IPv4 Address or Addresses \nAlternatively you can lookup a nameserver address or addresses from a domain name \n[T]\nSyntax: DNS [hostname/domain] [A/NS]", \&svs_us_dns);
}

sub void_us_dns {
	delete_sub 'init_us_dns';
	delete_sub 'svs_us_dns';
	cmd_del("utilserv/dns");
       delete_sub 'void_us_dns';
}

sub svs_us_dns {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("utilserv", $user, "Not enough parameters. Syntax: DNS [hostname/domain] [A/NS/MX]");
		return;
	}

	if (!defined($sargv[2])) {
		serv_notice("utilserv", $user, "Not enough parameters. Syntax: DNS [hostname/domain] [A/NS/MX]");
		return;
	}
	
	if (lc($sargv[2]) eq "a") {
  		my $res = new Net::DNS::Resolver;
  		my $query = $res->search($sargv[1], "A");
		my $rr;

  		if ($query) {
			serv_notice("utilserv", $user, "\002 ** IPv4 Addresses Found ** \002");
			serv_notice("utilserv", $user, "Hostname: ".$sargv[1]);
      			foreach $rr ($query->answer) {
          			next unless $rr->type eq "A";
				serv_notice("utilserv", $user, ">> ".$rr->address);
      			}
			serv_notice("utilserv", $user, "\002 ************************** \002");
			svsilog("utilserv", $user, "DNS", $sargv[1]." (Type: ".$sargv[2].")");
			svsflog('commands', uidInfo($user, 1).": UtilServ: DNS: $sargv[1] (Type: $sargv[2])");
			return;
  		}
  		else {
			svsilog("utilserv", $user, "DNS:FAIL:QUERY", $sargv[1], $sargv[2], $res->errorstring);
			svsflog('commands', uidInfo($user, 1).": UtilServ: DNS:FAIL:QUERY: $sargv[1] TYPE $sargv[2] ($res->errorstring)");
			serv_notice("utilserv", $user, "DNS Query Failed: ", $res->errorstring);
			return;
  		}

	}
	elsif (lc($sargv[2]) eq "ns") {
  		my $res = new Net::DNS::Resolver;
  		my $query = $res->query($sargv[1], "NS");
		my $rr;

  		if ($query) {
			serv_notice("utilserv", $user, "\002 **   NameServer Found   ** \002");
			serv_notice("utilserv", $user, "Hostname: ".$sargv[1]);
      			foreach $rr ($query->answer) {
          			next unless $rr->type eq "NS";
				serv_notice("utilserv", $user, ">> ".$rr->nsdname);
      			}
			serv_notice("utilserv", $user, "\002 ************************** \002");
			svsilog("utilserv", $user, "DNS", $sargv[1]." (Type: ".$sargv[2].")");
			svsflog('commands', uidInfo($user, 1).": UtilServ: DNS: $sargv[1] (Type: $sargv[2])");
			return;
  		}
  		else {
			svsilog("utilserv", $user, "DNS:FAIL:QUERY", $sargv[1], $sargv[2], $res->errorstring);
			svsflog('commands', uidInfo($user, 1).": UtilServ: DNS:FAIL:QUERY: $sargv[1] TYPE $sargv[2] ($res->errorstring)");
			serv_notice("utilserv", $user, "DNS Query Failed: ", $res->errorstring);
			return;
  		}

	}
	elsif (lc($sargv[2]) eq "mx") {
  		my $res = new Net::DNS::Resolver;
		my $rr;
		my @mx;

 		@mx = mx($res, $sargv[1]);
  		if (@mx) {
			serv_notice("utilserv", $user, "\002 **  Mail Servers Found  ** \002");
			serv_notice("utilserv", $user, "Hostname: ".$sargv[1]);
      			foreach $rr (@mx) {
				serv_notice("utilserv", $user, ">> ".$rr->preference." - ".$rr->exchange);
      			}
			serv_notice("utilserv", $user, "\002 ************************** \002");
			svsilog("utilserv", $user, "DNS", $sargv[1]." (Type: ".$sargv[2].")");
			svsflog('commands', uidInfo($user, 1).": UtilServ: DNS: $sargv[1] (Type: $sargv[2])");
  		}
  		else {
			svsilog("utilserv", $user, "DNS:FAIL:QUERY", $sargv[1], $sargv[2], $res->errorstring);
			svsflog('commands', uidInfo($user, 1).": UtilServ: DNS:FAIL:QUERY: $sargv[1] TYPE $sargv[2] ($res->errorstring)");
			serv_notice("utilserv", $user, "MX Lookup Failed: ", $res->errorstring);
			return;
  		}

	}
	else
	{
		serv_notice("utilserv", $user, "Invalid Record Type. Syntax: DNS [hostname/domain] [A/NS/MX]");
		return;
	}
}

1;
