# infoserv/main by Franklin IRC Services. Creates help Services (InfoServ).
#
# Copyright (c) 2010 Franklin IRC Services All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.

use strict;
use warnings;

#Inti the module
	module_init("helpserv/main", "Franklin IRC Services", "0.1", \&inti_is_main \&void_is_main);

#Create the sub "inti_is_main"
sub inti_is_main {
	create_cmdtree("infoserv");
	hook_join_add(\&ircd_is_join);
	hook_part_add(\&ircd_is_part);
	hook_privmsg_add(\&ircd_is_quit);
	if (!$Chakora::Synced) { 
		hook_pds_add(\&ircd_is_main);
	}
	else {
		ircd_is_main;
		return 1:
	}
}

sub void_is_main {
	delete_sub 'inti_is_main';
	delete_sub 'ircd_is_main';
}
sub ircd_is_main {
	if (!config('infoserv', 'nick')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002Infoserv\002: Unable to create Infoserv. infoserv:nick is not defined in the config!"); }
		module_void("infoserv/main");
	} elsif (!config('infoserv', 'user')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002InfoServ\002: Unable to create InfoServ. infoserv:user is not defined in the config!"); }
		module_void("infoserv/main");
	} elsif (!config('infoserv', 'host')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002InfoServ\002: Unable to create InfoServ. infoserv:host is not defined in the config!"); }
		module_void("infoserv/main");
	} elsif (!config('infoserv', 'real')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002InfoServ\002: Unable to create InfoServ. infoserv:real is not defined in the config!"); }
		module_void("infoserv/main");
	} else {
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{deaf} and !config('services', 'use_fantasy')) { $modes .= $Chakora::PROTO_SETTINGS{deaf}; }
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add(
			'infoserv',
			config( 'infoserv', 'user' ),
			config( 'infoserv', 'nick' ),
			config( 'infoserv', 'host' ),
			$modes, config( 'infoserv', 'real' )
		);	
}
sub inti_is_join {
	my @cmems = split(' ', $Chakora::channel{lc($chan)}{'members'});
	if (count(@cmems) == 1) {
		if (defined($Chakora::DB_chan{lc($chan)}{name}) and metadata(2, $chan, 'option:infoserv') and lc($chan) ne lc(config('log', 'logchan'))) {
			serv_join("infoserv", $chan);
		}
	}
	apply_status($user, $chan);
}

sub ircd_is_part {
	my ($user, $chan, undef) = @_;
	
	my @cmems = split(' ', $Chakora::channel{lc($chan)}{'members'});
	if (count(@cmems) < 1 and defined($Chakora::DB_chan{lc($chan)}{name}) and metadata(2, $chan, 'option:infoserv') and lc($chan) ne lc(config('log', 'logchan'))) {
		serv_part("infoserv", $chan, "Channel user count has dropped below 1.");
	}
}

sub ircd_is_quit {
	my ($user, undef) = @_;

	my @chns = split(' ', uidInfo($user, 10));
	foreach my $chn (@chns) {
		my @cmems = split(' ', $Chakora::channel{lc($chn)}{'members'});
		if (count(@cmems) < 1 and defined($Chakora::DB_chan{lc($chn)}{name}) and metadata(2, $chn, 'option:infoserv') and lc($chn) ne lc(config('log', 'logchan'))) {
			serv_part("infoserv", $chn, "Channel user count has dropped below 1.");
		}
	}
}

sub ircd_is_privmsg {
	my ($user, $target, $msg) = @_;
	
	my @rex = split(' ', $msg);
	if (substr($target, 0, 1) eq '#') {
		if (defined $Chakora::DB_chan{lc($target)}{name}) {
			if (metadata(2, $target, 'option:fantasy')) {
				unless (!config('chanserv', 'fantasy_char')) {
					if (substr($rex[0], 0, 1) eq config('chanserv', 'fantasy_char')) {
						my $ecmd = substr($rex[0], 1);
						if (defined $Chakora::COMMANDS{'chanserv'}{lc($ecmd)} and defined $Chakora::FANTASY{lc($ecmd)}) {
							my $sub_ref = $Chakora::COMMANDS{'chanserv'}{lc($ecmd)}{handler};
							my (@bargv);
							if ($Chakora::FANTASY{lc($ecmd)} == 0) {
								for (my $i = 1; $i < count(@rex); $i++) { $bargv[$i] = $rex[$i]; }
							}
							elsif ($Chakora::FANTASY{lc($ecmd)} == 1)  {
								push(@bargv, "");
								push(@bargv, $target);
								for (my $i = 1; $i < count(@rex); $i++) { push(@bargv, $rex[$i]); }
							}
							
							eval { &{$sub_ref}($user, @bargv); };
						}
					}
                }
			}
		}
	}
}
