# dnsbl/main by Russell Bradford. Creates the DNSBL service.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;
use Net::DNS;

module_init("dnsbl/main", "Russell Bradford", "0.1", \&init_dns_main, \&void_dns_main, "all");

sub init_dns_main {
	hook_kill_add(\&ircd_dns_kill);
	hook_uid_add(\&ircd_dns_uid);
	create_cmdtree("dnsbl");
	if (!$Chakora::synced) { hook_pds_add(\&svs_dns_main); return 1; }
	else { svs_dns_main(); }
}

sub void_dns_main {
	delete_sub 'init_dns_main';
	delete_sub 'svs_dns_main';
	hook_pds_del(\&svs_dns_main);
	serv_del('DNSBL');
	delete_cmdtree("dnsbl");
	hook_uid_del(\&ircd_dns_uid);
	hook_kill_del(\&ircd_dns_kill);
	delete_sub 'ircd_dns_kill';
	delete_sub 'ircd_dns_uid';
	delete_sub 'void_dns_main';
}

sub svs_dns_main {
	if (!config('dnsbl', 'nick')) {
		svsflog('modules', 'Unable to create DNSBL. dnsbl:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002DNSBL\002: Unable to create DNSBL. dnsbl:nick is not defined in the config!"); }
		module_void("dnsbl/main");
	} elsif (!config('dnsbl', 'user')) {
		svsflog('modules', 'Unable to create DNSBL. dnsbl:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002DNSBL\002: Unable to create DNSBL. dnsbl:user is not defined in the config!"); }
		module_void("dnsbl/main");
	} elsif (!config('dnsbl', 'host')) {
		svsflog('modules', 'Unable to create DNSBL. dnsbl:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002DNSBL\002: Unable to create DNSBL. dnsbl:host is not defined in the config!"); }
		module_void("dnsbl/main");
	} elsif (!config('dnsbl', 'real')) {
		svsflog('modules', 'Unable to create DNSBL. dnsbl:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002DNSBL\002: Unable to create DNSBL. dnsbl:real is not defined in the config!"); }
		module_void("dnsbl/main");
	} else {
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add('dnsbl', config('dnsbl', 'user'), config('dnsbl', 'nick'), config('dnsbl', 'host'), $modes, config('dnsbl', 'real'));
	}
}

sub ircd_dns_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'dnsbl'}) {
		serv_del("DNSBL");
		ircd_dns_main();
	}
}

sub ircd_dns_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'dnsbl'}) {
		serv_del("DNSBL");
		ircd_dns_main();
	}
}

sub ircd_dns_uid {
	my ( $uid, $nick, $user, $host, $mask, $ip, $server ) = @_;
	my ($ipp1,$ipp2,$ipp3,$ipp4)=split /\./,$ip;
	my $reverse = "$ipp4.$ipp3.$ipp2.$ipp1";

	my @dnsbls = ('dnsbl.ahbl.org', 'dnsbl.infinityirc.com', 'tor.dnsbl.sectoor.de', 'dnsbl.dronebl.org', 'dnsbl.swiftbl.net', 'rbl.efnet.org', 'dnsbl.proxybl.org', 'tor.dan.me.uk', 'dnsbl.technoirc.org');

	foreach (@dnsbls) {
		my $res = new Net::DNS::Resolver;
		my $query = $res->search("$reverse.$_", "A");
		my $rr;

		if ($query) {
      			foreach $rr ($query->answer) {
       	   		next unless $rr->type eq "A";
				my ($ipr1,$ipr2,$ipr3,$ipr4)=split /\./,$rr->address;
				if($ipr4 > 0 and $ipr4 < 30)
				{
					serv_kill('dnsbl', $uid, "Your connection is listed in $_. This may be because you have spammed, or are on a compromised connection. (Reason: $ipr4)"); 
					event_kill('dnsbl', $uid, "Your connection is listed in $_. This may be because you have spammed, or are on a compromised connection. (Reason: $ipr4)");
					return;
				}
      			}
		}
	}

}
