# chanserv/halfop by The Chakora Project. Adds a HALFOP/DEHALFOP command to ChanServ allowing one to (de)halfop themselves or another user.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/halfop", "The Chakora Project", "0.1", \&sinit_cs_halfop, \&void_cs_halfop);

sub sinit_cs_halfop {
	if ($Chakora::synced) { init_cs_halfop(); }
	else { hook_pds_add(\&init_cs_halfop); }
}

sub init_cs_halfop {
	if (!defined($Chakora::PROTO_SETTINGS{halfop})) {
		svsflog("modules", "Unable to load chanserv/halfop, halfop prefix not available.");
		if ($Chakora::synced) { logchan("operserv", "\002chanserv/halfop\002: Unable to load, this protocol does not support the halfop prefix."); }
		module_void("chanserv/halfop");
	}
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/halfop", "Halfops you or another user on a channel.", "HALFOP will allow you to either halfop \nyourself or another user in a channel\nthat you have the +h flag in. \n[T]\nSyntax: HALFOP <#channel> [user]", \&svs_cs_halfop);
	cmd_add("chanserv/dehalfop", "Dehalfops you or another user on a channel.", "DEHALFOP will allow you to either\ndehalfop yourself or another user in\na channel that you have the +h flag in. \n[T]\nSyntax: DEHALFOP <#channel> [user]", \&svs_cs_dehalfop);
	fantasy("halfop", 1);
	fantasy("dehalfop", 1);
	if (!flag_exists("h")) {
		flaglist_add("h", "Allows the use of the HALFOP/DEHALFOP command");
	}
}

sub void_cs_halfop {
	delete_sub 'sinit_cs_halfop';
	delete_sub 'init_cs_halfop';
	delete_sub 'svs_cs_halfop';
	delete_sub 'svs_cs_dehalfop';
	hook_pds_del(\&init_cs_halfop);
	fantasy_del("halfop");
	fantasy_del("dehalfop");
	cmd_del("chanserv/halfop");
	cmd_del("chanserv/dehalfop");
	flaglist_del("h");
	delete_sub 'void_cs_halfop';
}

sub svs_cs_halfop {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: HALFOP <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'h')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[2])) {
		if (!ison($user, $chan)) {
			serv_notice("chanserv", $user, "You are not in \002$chan\002.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{halfop}." ".$user);
		svsilog("chanserv", $user, "HALFOP", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: HALFOP: $chan");
	}
	else {
		my $tu = nickUID($sargv[2]);
		if (!$tu) {
			serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
			return;
		}
		if (!ison($tu, $chan)) {
			serv_notice("chanserv", $user, "\002$sargv[2]\002 is not in \002$chan\002.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{halfop}." ".$tu);
		serv_notice("chanserv", $tu, "You have been HALFOP'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "HALFOP", $sargv[2]." in ".$chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: HALFOP: $sargv[2] in $chan");
	}
}

sub svs_cs_dehalfop {
        my ($user, @sargv) = @_;

        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this command.");
                return;
        }
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: DEHALFOP <#channel> [user]");
                return;
        }
        my $acc = uidInfo($user, 9);
        my $chan = $sargv[1];
        if (!is_registered(2, $chan)) {
                serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
                return;
        }
        if (!has_flag($acc, $chan, 'h')) {
                serv_notice("chanserv", $user, "Permission denied.");
                return;
	}
        if (!defined($sargv[2])) {
                if (!ison($user, $chan)) {
                        serv_notice("chanserv", $user, "You are not in \002$chan\002.");
                        return;
                }
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{halfop}." ".$user);
                svsilog("chanserv", $user, "DEHALFOP", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEHALFOP: $chan");
        }
        else {
                my $tu = nickUID($sargv[2]);
                if (!$tu) {
                        serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
                        return;
                }
                if (!ison($tu, $chan)) {
                        serv_notice("chanserv", $user, "\002$sargv[2]\002 is not in \002$chan\002.");
                        return;
                }
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{halfop}." ".$tu);
                serv_notice("chanserv", $tu, "You have been DEHALFOP'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
                svsilog("chanserv", $user, "DEHALFOP", $sargv[2]." in ".$chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEHALFOP: $sargv[2] in $chan");
        }
}

