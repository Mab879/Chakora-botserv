# nickserv/main by The Chakora Project. Creates nickname services (NickServ).
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD Licecse (docs/LICENSE - http://www.opecsource.org/licecses/bsd-licecse.php)
use strict;
use warnings;

module_init("nickserv/main", "The Chakora Project", "0.3", \&init_ns_main, \&void_ns_main, "all");

sub init_ns_main {
	create_cmdtree("nickserv");
	hook_kill_add(\&ircd_ns_kill);
	hook_kick_add(\&ircd_ns_kick);
	hook_nick_add(\&ircd_ns_nick);
	if (-e "$Chakora::ROOT_SRC/../etc/idrecover.db") { hook_eos_add(\&ircd_ns_restart); }
	if (!$Chakora::synced) { hook_pds_add(\&ircd_ns_main); }
	else { ircd_ns_main(); }
}

sub void_ns_main {
	delete_sub 'init_ns_main';
	delete_sub 'ircd_ns_main';
	delete_sub 'ircd_ns_kill';
	delete_sub 'ircd_ns_kick';
	delete_sub 'ircd_ns_nick';
	delete_sub 'ircd_ns_restart';
	hook_pds_del(\&svs_ns_main);
	serv_del('NickServ');
	hook_kill_del(\&ircd_ns_kill);
	hook_kick_del(\&ircd_ns_kick);
	hook_nick_del(\&ircd_ns_nick);
	hook_eos_del(\&ircd_ns_restart);
	delete_cmdtree("nickserv");
	delete_sub 'void_ns_main';
}

sub ircd_ns_main {
	if (!config('nickserv', 'nick')) {
		svsflog('modules', 'Unable to create NickServ. nickserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002NickServ\002: Unable to create NickServ. nickserv:nick is not defined in the config!"); }
		module_void("nickserv/main");
	} elsif (!config('nickserv', 'user')) {
		svsflog('modules', 'Unable to create NickServ. nickserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002NickServ\002: Unable to create NickServ. nickserv:user is not defined in the config!"); }
		module_void("nickserv/main");
	} elsif (!config('nickserv', 'host')) {
		svsflog('modules', 'Unable to create NickServ. nickserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002NickServ\002: Unable to create NickServ. nickserv:host is not defined in the config!"); }
		module_void("nickserv/main");
	} elsif (!config('nickserv', 'real')) {
		svsflog('modules', 'Unable to create NickServ. nickserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002NickServ\002: Unable to create NickServ. nickserv:real is not defined in the config!"); }
		module_void("nickserv/main");
	} else {
		my $modes = '+io';
		if (lc(config('server', 'ircd')) eq 'inspircd12') {
			if ($Chakora::PROTO_SETTINGS{god}) {
				$modes .= 'k';
			}
		} elsif (lc(config('server', 'ircd')) eq 'charybdis') {
			$modes .= 'S';
		} else {
			svsflog('modules', 'Unable to create NickServ. Unsupported protocol!');
			if ($Chakora::synced) { logchan('operserv', "\002NickServ\002: Unable to create NickServ. Unsupported protocol!"); }
			module_void("nickserv/main");
		}
		serv_add(
			'nickserv',
			config( 'nickserv', 'user' ),
			config( 'nickserv', 'nick' ),
			config( 'nickserv', 'host' ),
			$modes, config( 'nickserv', 'real' )
		);
	}	
}

sub ircd_ns_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'nickserv'}) {
		serv_del("NickServ");
		ircd_ns_main();
	}
	else {
		foreach my $key (keys %Chakora::svsuid) {
			if ($target eq $Chakora::svsuid{$key}) {
				return;
			}
		}
	}
}

sub ircd_ns_kick {
	my ($user, $chan, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'nickserv'}) {
		if (lc($chan) ne config('log', 'logchan') and !defined($Chakora::DB_chan{lc($chan)}{name})) {
			return;
		}	
		serv_join("nickserv", $chan);
		serv_kick("nickserv", $chan, $user, "Please do not kick services.");
	}
}

sub ircd_ns_nick {
	my ($user, $newnick) = @_;
	if (is_identified($user)) {
		metadata_add(1, uidInfo($user, 9), "data:realhost", $newnick."!".uidInfo($user,2)."@".uidInfo($user,3)." ".uidInfo($user,5));
	}
}

sub ircd_ns_restart {
	if (-e "$Chakora::ROOT_SRC/../etc/idrecover.db") {
		open FILE, "<$Chakora::ROOT_SRC/../etc/idrecover.db" or return;
		my @lines = <FILE>;
		close FILE;
		`rm $Chakora::ROOT_SRC/../etc/idrecover.db`;
		
		foreach my $line (@lines) {
			my @rex = split(' ', $line);
			
			if (defined $Chakora::uid{$rex[0]}) {
				if ($Chakora::uid{$rex[0]}{'nick'} eq $rex[1] and
					$Chakora::uid{$rex[0]}{'user'} eq $rex[2] and
					$Chakora::uid{$rex[0]}{'host'} eq $rex[3] and
					$Chakora::uid{$rex[0]}{'ip'} eq $rex[4] and
					$Chakora::uid{$rex[0]}{'server'} eq $rex[5]) {
						serv_notice("nickserv", $rex[0], "Automatically re-identifying you to your account.");
						serv_accountname($rex[0], $rex[6]);
						$Chakora::uid{$rex[0]}{'account'} = $rex[6];
						event_identify($rex[0], uidInfo($rex[0], 9));
				}
			}
		}
	}
}

1;
