# chanserv/main by The Chakora Project. Creates channel services (ChanServ).
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD Licecse (docs/LICENSE - http://www.opecsource.org/licecses/bsd-licecse.php)
use strict;
use warnings;

module_init("chanserv/main", "The Chakora Project", "0.3", \&init_cs_main, \&void_cs_main, "all");

sub init_cs_main {
	create_cmdtree("chanserv");
	hook_kill_add(\&ircd_cs_kill);
	hook_join_add(\&ircd_cs_join);
	hook_part_add(\&ircd_cs_part);
	hook_quit_add(\&ircd_cs_quit);
	hook_kick_add(\&ircd_cs_kick);
	hook_identify_add(\&ircd_cs_ns_id);
	if (!$Chakora::synced) { hook_pds_add(\&ircd_cs_main); }
	else { ircd_cs_main(); }
}

sub void_cs_main {
	delete_sub 'init_cs_main';
	delete_sub 'ircd_cs_main';
	delete_sub 'ircd_cs_kill';
	delete_sub 'ircd_cs_join';
	delete_sub 'ircd_cs_part';
	delete_sub 'ircd_cs_quit';
	delete_sub 'ircd_cs_kick';
	delete_sub 'ircd_cs_ns_id';
	delete_sub 'apply_status';
	delete_sub 'flags';
	hook_pds_del(\&svs_hs_main);
	serv_del('ChanServ');
	hook_kill_del(\&ircd_cs_kill);
	hook_join_del(\&ircd_cs_join);
	hook_part_del(\&ircd_cs_part);
	hook_quit_del(\&ircd_cs_quit);
	hook_kick_del(\&ircd_cs_kick);
	hook_identify_del(\&ircd_cs_ns_id);
	delete_cmdtree("chanserv");
	delete_sub 'void_cs_main';
}

sub ircd_cs_main {
	if (!config('chanserv', 'nick')) {
		svsflog('modules', 'Unable to create ChanServ. chanserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002ChanServ\002: Unable to create ChanServ. chanserv:nick is not defined in the config!"); }
		module_void("chanserv/main");
	} elsif (!config('chanserv', 'user')) {
		svsflog('modules', 'Unable to create ChanServ. chanserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002ChanServ\002: Unable to create ChanServ. chanserv:user is not defined in the config!"); }
		module_void("chanserv/main");
	} elsif (!config('chanserv', 'host')) {
		svsflog('modules', 'Unable to create ChanServ. chanserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002ChanServ\002: Unable to create ChanServ. chanserv:host is not defined in the config!"); }
		module_void("chanserv/main");
	} elsif (!config('chanserv', 'real')) {
		svsflog('modules', 'Unable to create ChanServ. chanserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002ChanServ\002: Unable to create ChanServ. chanserv:real is not defined in the config!"); }
		module_void("chanserv/main");
	} else {
		my $modes = '+io';
		if (lc(config('server', 'ircd')) eq 'inspircd12') {
			if ($Chakora::PROTO_SETTINGS{god}) {
				$modes .= 'k';
			}
		} elsif (lc(config('server', 'ircd')) eq 'charybdis') {
			$modes .= 'S';
		} else {
			svsflog('modules', 'Unable to create ChanServ. Unsupported protocol!');
			if ($Chakora::synced) { logchan('operserv', "\002ChanServ\002: Unable to create ChanServ. Unsupported protocol!"); }
			module_void("chanserv/main");
		}
		serv_add(
			'chanserv',
			config( 'chanserv', 'user' ),
			config( 'chanserv', 'nick' ),
			config( 'chanserv', 'host' ),
			$modes, config( 'chanserv', 'real' )
		);	
        foreach my $key ( keys %Chakora::DB_chan ) {
            unless (!defined( $Chakora::DB_chan{$key}{name})) {
				if (defined $Chakora::channel{$key}{'members'}) {
					my @cmems = split(' ', $Chakora::channel{$key}{'members'});
					if (count(@cmems) == 1 or count(@cmems) > 1 and metadata(2, $key, 'option:guard')) {
						serv_join("chanserv", $Chakora::DB_chan{$key}{name});
					}
				}
            }
        }
	}
}

sub ircd_cs_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'chanserv'}) {
		serv_del("ChanServ");
		ircd_cs_main();
	}
	else {
		foreach my $key (keys %Chakora::svsuid) {
			if ($target eq $Chakora::svsuid{$key}) {
				return;
			}
		}
		
		my @chns = split(' ', uidInfo($user, 10));
		foreach my $chn (@chns) {
			my @cmems = split(' ', $Chakora::channel{lc($chn)}{'members'});
			if (count(@cmems) < 1 and defined($Chakora::DB_chan{lc($chn)}{name}) and metadata(2, $chn, 'option:guard') and lc($chn) ne lc(config('log', 'logchan'))) {
				serv_part("chanserv", $chn, "Channel user count has dropped below 1.");
			}
		}
	}
}

sub ircd_cs_join {
	my ($user, $chan) = @_;
	
	my @cmems = split(' ', $Chakora::channel{lc($chan)}{'members'});
	if (count(@cmems) == 1) {
		if (defined($Chakora::DB_chan{lc($chan)}{name}) and metadata(2, $chan, 'option:guard') and lc($chan) ne lc(config('log', 'logchan'))) {
			serv_join("chanserv", $chan);
		}
	}
	apply_status($user, $chan);
}

sub ircd_cs_part {
	my ($user, $chan, $msg) = @_;
	
	my @cmems = split(' ', $Chakora::channel{lc($chan)}{'members'});
	if (count(@cmems) < 1 and defined($Chakora::DB_chan{lc($chan)}{name}) and metadata(2, $chan, 'option:guard') and lc($chan) ne lc(config('log', 'logchan'))) {
		serv_part("chanserv", $chan, "Channel user count has dropped below 1.");
	}
}

sub ircd_cs_kick {
	my ($user, $chan, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'chanserv'}) {
		if (lc($chan) ne config('log', 'logchan') and !defined($Chakora::DB_chan{lc($chan)}{name})) {
			return;
		}
	
		serv_join("chanserv", $chan);
		serv_kick("chanserv", $chan, $user, "Please do not kick services.");
	}
	else {
		my @cmems = split(' ', $Chakora::channel{lc($chan)}{'members'});
		if (count(@cmems) < 1 and defined($Chakora::DB_chan{lc($chan)}{name}) and metadata(2, $chan, 'option:guard') and lc($chan) ne lc(config('log', 'logchan'))) {
			serv_part("chanserv", $chan, "Channel user count has dropped below 1.");
		}
	}
}

sub ircd_cs_quit {
	my ($user, $msg) = @_;

	my @chns = split(' ', uidInfo($user, 10));
	foreach my $chn (@chns) {
		my @cmems = split(' ', $Chakora::channel{lc($chn)}{'members'});
		if (count(@cmems) < 1 and defined($Chakora::DB_chan{lc($chn)}{name}) and metadata(2, $chn, 'option:guard') and lc($chn) ne lc(config('log', 'logchan'))) {
			serv_part("chanserv", $chn, "Channel user count has dropped below 1.");
		}
	}
}

sub ircd_cs_ns_id {
	my ($user, $account) = @_;

	my @chns = split(' ', $Chakora::uid{$user}{'chans'});
	foreach my $chn (@chns) {
		apply_status($user, $chn);
	}
}

sub flags {
    my ( $chan, $user, $flags ) = @_;
    $chan = lc($chan);
    foreach my $key ( keys %Chakora::DB_chanflags ) {
        if ( $Chakora::DB_chanflags{$key}{chan} eq $chan
            and lc( $Chakora::DB_chanflags{$key}{account} ) eq lc($user) )
        {
            $Chakora::DB_chanflags{$key}{flags} = $flags;
            return;
        }
    }
    $Chakora::DBCFLAST += 1;
    $Chakora::DB_chanflags{$Chakora::DBCFLAST}{chan}    = $chan;
    $Chakora::DB_chanflags{$Chakora::DBCFLAST}{account} = $user;
    $Chakora::DB_chanflags{$Chakora::DBCFLAST}{flags}   = $flags;
}

sub apply_status {
	my ($user, $chan) = @_;
	
	if (!uidInfo($user, 9)) {
		return;
	}

	my $account = uidInfo($user, 9);

	my ($modes);
	if (has_flag($account, $chan, "b")) {
		my $mask = uidInfo($user, 4);
		serv_mode("chanserv", $chan, "+b *!*@".$mask);
		serv_kick("chanserv", $chan, $user, "Banned.");
		return;
	}
        if (metadata(2, $chan, 'option:nostatus')) {
                return;
        }
        if (metadata(1, $account, 'flag:nostatus')) {
                return;
        }
	if (has_flag($account, $chan, "Q") and defined($Chakora::PROTO_SETTINGS{owner})) {
		$modes .= $Chakora::PROTO_SETTINGS{owner};
	}
	if (has_flag($account, $chan, "A") and defined($Chakora::PROTO_SETTINGS{admin})) {
		$modes .= $Chakora::PROTO_SETTINGS{admin};
	}
	if (has_flag($account, $chan, "O") and defined($Chakora::PROTO_SETTINGS{op})) {
		$modes .= $Chakora::PROTO_SETTINGS{op};
	}
	if (has_flag($account, $chan, "H") and defined($Chakora::PROTO_SETTINGS{halfop})) {
		$modes .= $Chakora::PROTO_SETTINGS{halfop};
	}
	if (has_flag($account, $chan, "V") and defined($Chakora::PROTO_SETTINGS{voice})) {
		$modes .= $Chakora::PROTO_SETTINGS{voice};
	}

	if (defined($modes)) {
		if (length($modes) == 0) {
			return;
		}

		my ($tg);
		my $calc = length($modes);
		while ($calc > 0) {
			$tg .= ' '.$user;
			$calc -= 1;
		}
		
		serv_mode("chanserv", $chan, '+'.$modes.$tg);
	}
}
