# dnsbl/scan by Russell Bradford. Adds SCAN to DNSBL which will allow users to lookup a ip address in the defined dnsbl's
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;


module_init("dnsbl/scan", "Russell Bradford", "1.0", \&init_dns_scan, \&void_dns_scan, "all");

sub init_dns_scan {
	if(!eval { require Net::DNS; 1; })
	{
		svsflog("modules", "Unable to load dnsbl/scan, Net::DNS not installed.");
		if ($Chakora::synced) { logchan("operserv", "\002dnsbl/scan\002: Unable to load, Net::DNS not installed."); }
		module_void("dnsbl/scan");
		return 0;
	}
	if(!eval { require Config::Scoped;; 1; })
	{
		svsflog("modules", "Unable to load dnsbl/scan, Config::Scoped not installed.");
		if ($Chakora::synced) { logchan("operserv", "\002dnsbl/scan\002: Unable to load, Config::Scoped not installed."); }
		module_void("dnsbl/scan");
		return 0;
	}
	cmd_add("dnsbl/scan", "Lookup a IP Address in DNSBL's", "Lookup up a IP Address in the \ndefined list of DNSBL's. \nCurrently only IPv4 IP addresses are \nsupported. \n[T]\nSyntax: SCAN [IP Address]", \&svs_dns_scan);
}

sub void_dns_scan {
	delete_sub 'init_dns_scan';
	delete_sub 'svs_dns_scan';
	cmd_del("dnsbl/scan");
       delete_sub 'void_dns_scan';
}

sub svs_dns_scan {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("dnsbl", $user, "Not enough parameters. Syntax: SCAN [IP Address]");
		return;
	}

	if ($sargv[1] =~ m/^(\d\d?\d?)\.(\d\d?\d?)\.(\d\d?\d?)\.(\d\d?\d?)/ )
	{
		serv_notice("dnsbl", $user, "\002 ******* DNSBL Scan ******* \002");

		my ($ipp1,$ipp2,$ipp3,$ipp4)=split /\./,$sargv[1];
		my $reverse = "$ipp4.$ipp3.$ipp2.$ipp1";
		my $found = 0;
		my $dconf = `pwd`;
		chomp $dconf;
  		my $parser = Config::Scoped->new( file => "$dconf/../modules/dnsbl/dnsbl.conf", );
  		my $config = $parser->parse;

		for (my $i = 0; $i < 20; $i++)
		{
			if($config->{list}->{$i})
			{
				my $res = new Net::DNS::Resolver;
				my $query = $res->search("$reverse.$config->{list}->{$i}", "A");
				my $rr;

				if ($query) {
      					foreach $rr ($query->answer) {
       	   				next unless $rr->type eq "A";
						my ($ipr1,$ipr2,$ipr3,$ipr4)=split /\./,$rr->address;
						if($ipr4 > 0 and $ipr4 < 30)
						{
							serv_notice("dnsbl", $user, "$sargv[1] is listed in $config->{list}->{$i} (Reason: $ipr4)");
							$found++;
						}
      					}
				}
				else
				{
					serv_notice("dnsbl", $user, "$sargv[1] is not listed in $config->{list}->{$i}");
				}
			}
		}
		serv_notice("dnsbl", $user, "\002 ************************** \002");
		svsilog("dnsbl", $user, "SCAN", $sargv[1]." (Found in \002$found\002 Blacklists)");
		svsflog('commands', uidInfo($user, 1).": DNSBL: SCAN: $sargv[1] (Found in $found Blacklists)");
		return;
	}
	else
	{
		serv_notice("dnsbl", $user, "Syntax Error. The address specified is not a valid IPv4 Address");
		return;
	}
}

1;
