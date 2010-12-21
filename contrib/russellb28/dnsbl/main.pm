# dnsbl/main by Russell Bradford. Creates the DNSBL service.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("dnsbl/main", "Russell Bradford", "0.1", \&init_dns_main, \&void_dns_main);

sub init_dns_main {
	if(!eval { require Net::DNS; 1; })
	{
		svsflog("modules", "Unable to load dnsbl/main, Net::DNS not installed.");
		if ($Chakora::synced) { logchan("operserv", "\002dnsbl/main\002: Unable to load, Net::DNS not installed."); }
		module_void("dnsbl/main");
		return 0;
	}
	if(!eval { require Config::Scoped;; 1; })
	{
		svsflog("modules", "Unable to load dnsbl/main, Config::Scoped not installed.");
		if ($Chakora::synced) { logchan("operserv", "\002dnsbl/main\002: Unable to load, Config::Scoped not installed."); }
		module_void("dnsbl/main");
		return 0;
	}
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
					if($ipr1 == 127 and $ipr4 > 0 and $ipr4 < 30)
					{
						svsilog("dnsbl", $uid, "KILLED: $ip\002 is listed in \002$config->{list}->{$i}\002");
						svsflog('commands', uidInfo($uid, 1).": DNSBL: KILLED: $nick ($ip) is listed in $config->{list}->{$i}");
						serv_kill('dnsbl', $uid, "Your connection is listed in $config->{list}->{$i}. This may be because you have spammed, or are on a compromised connection. (Reason: $ipr4)"); 
						event_kill('dnsbl', $uid, "Your connection is listed in $config->{list}->{$i}. This may be because you have spammed, or are on a compromised connection. (Reason: $ipr4)");
						return;
					}
      				}
			}
		}
	}

}
