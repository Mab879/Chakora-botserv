# botserv/main by The Chakora Project. Creates channel bot services (BotServ).
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("botserv/main", "Franklin  IRC Services", "0.1", \&init_ns_main, \&void_ns_main);

sub init_bs_main {
	create_cmdtree("botserv");
	hook_kill_add(\&ircd_bs_kill);
	hook_kick_add(\&ircd_bs_kick);
	hook_nick_add(\&ircd_bs_nick);
	hook_chghost_add(\&ircd_bs_chghost);
	hook_chgident_add(\&ircd_bs_chgident);
	if (-e "$Chakora::ROOT_SRC/../ect/idrecover.db") {hook_eos_add(\&ircd_bs_restart); }
	if (!$Chakora::synced) { hook_pds_add(\&ircd_ns_main); }
}
sub void_ns_main {
	delete_sub 'init_bs_main';
	delete_sub 'ircd_bs_main';
	delete_sub 'ircd_bs_kill';
	delete_sub 'ircd_bs_kick';
	delete_sub 'ircd_bs_nick';
	delete_sub 'ircd_bs_restart';
        delete_sub 'ircd_bs_chghost';
        delete_sub 'ircd_bs_chgident';
	hook_pds_del(\&svs_ns_main);
	serv_del('BotServ');
	hook_kill_del(\&ircd_bs_kill);
	hook_kick_del(\&ircd_bs_kick);
	hook_nick_del(\&ircd_bs_nick);
	hook_eos_del(\&ircd_bs_restart);
        hook_chghost_del(\&ircd_bs_chghost);
        hook_chgident_del(\&ircd_bs_chgident);
	delete_cmdtree("banserv");
	delete_sub 'void_bs_main';
}
sub ircd_bs_main {
	if(!config('botserv', 'bot'))
	svsflog('modules', 'Unable to create BotServ. botserv:nick is not defined in the config!');
	if ($Chakora::synced) { logchan('operserv', "\002BotServ\002: Unable to create BotServ. botserv:nick is not defined in the config!"); }
		module_void("botserv/main");
	} elsif (!config('botserv', 'user')) {
		svsflog('modules', 'Unable to create BotServ. botserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002botserv\002: Unable to create botserv. botserv:user is not defined in the config!"); }
		module_void("botserv/main");
	} elsif (!config('botserv', 'host')) {
		svsflog('modules', 'Unable to create botserv. botserv:host is not defined in the config!');
		module_void("botserv/main");
	} elsif (!config('botserv', 'real')) {
		svsflog('modules', 'Unable to create botserv. botserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002BotServ\002: Unable to create botserv. botserv:real is not defined in the config!"); }
		module_void("botserv/main");
	} 
else {
		my $modes = '+io';
                if (defined $Chakora::PROTO_SETTINGS{deaf} and !config('services', 'use_fantasy')) { $modes .= $Chakora::PROTO_SETTINGS{deaf}; }
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add(
			'botserv',
			config( 'botserv', 'user' ),
			config( 'botserv', 'nick' ),
			config( 'botserv', 'host' ),
			$modes, config( 'botserv', 'real' )
		);
	}	
}
sub ircd_bs_kill {
	my ($user, $target, undef) = @_;
	
	if ($target eq svsUID("botserv")) {
		serv_del("BotServ");
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
sub ircd_bs_kick {
	my ($user, $chan, $target, undef) = @_;
	
	if ($target eq svsUID("botserv")) {
		serv_join("botserv", $chan);
		serv_kick("botserv", $chan, $user, "Please do not kick services.");
	}
}
sub ircd_bs_nick {
	my ($user, $newnick) = @_;
	if (is_identified($user)) {
		metadata_add(1, uidInfo($user, 9), "data:realhost", $newnick."!".uidInfo($user,2)."@".uidInfo($user,3)." ".uidInfo($user,5));
	}
}
sub ircd_bs_chghost {
        my ($user, undef, $new) = @_;
        if (is_identified($user)) {
                metadata_add(1, uidInfo($user, 9), "data:realhost", uidInfo($user,1)."!".uidInfo($user,2)."@".$new." ".uidInfo($user,5));
        }
}
sub ircd_n\bs_chgident {
        my ($user, undef, $new) = @_;
        if (is_identified($user)) {
                metadata_add(1, uidInfo($user, 9), "data:realhost", uidInfo($user,1)."!".$new."@".uidInfo($user,3)." ".uidInfo($user,5));
        }
}
sub ircd_bs_restart {
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
