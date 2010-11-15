# chanserv/owner by The Chakora Project. Adds a OWNER/DEOWNER command to ChanServ allowing one to (de)owner themselves or another user.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/owner", "The Chakora Project", "0.1", \&sinit_cs_owner, \&void_cs_owner);

sub sinit_cs_owner {
	if ($Chakora::synced) { init_cs_owner(); }
	else { hook_pds_add(\&init_cs_owner); }
}

sub init_cs_owner {
	if (!defined($Chakora::PROTO_SETTINGS{owner})) {
		svsflog("modules", "Unable to load chanserv/owner, owner prefix not available.");
		if ($Chakora::synced) { logchan("operserv", "\002chanserv/owner\002: Unable to load, this protocol does not support the owner prefix."); }
		module_void("chanserv/owner");
	}
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/owner", "Owners you or another user on a channel.", "OWNER will allow you to either owner \nyourself or another user in a channel\nthat you have the +q flag in.\n[T]\nSyntax: OWNER <#channel> [user]", \&svs_cs_owner);
	cmd_add("chanserv/deowner", "Deowners you or another user on a channel.", "DEOWNER will allow you to either\ndeowner yourself or another user in\na channel that you have the +q flag in.\n[T]\nSyntax: DEOWNER <#channel> [user]", \&svs_cs_deowner);
	fantasy("owner", 1);
	fantasy("deowner", 1);
	if (!flag_exists("q")) {
		flaglist_add("q", "Allows the use of the OWNER/DEOWNER command");
	}
}

sub void_cs_owner {
	delete_sub 'sinit_cs_owner';
	delete_sub 'init_cs_owner';
	delete_sub 'svs_cs_owner';
	delete_sub 'svs_cs_deowner';
	hook_pds_del(\&init_cs_owner);
	fantasy_del("owner");
	fantasy_del("deowner");
	cmd_del("chanserv/owner");
	cmd_del("chanserv/deowner");
	flaglist_del("q");
	delete_sub 'void_cs_owner';
}

sub svs_cs_owner {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: OWNER <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'q')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[2])) {
		if (!ison($user, $chan)) {
			serv_notice("chanserv", $user, "You are not in \002$chan\002.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{owner}." ".$user);
		svsilog("chanserv", $user, "OWNER", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: OWNER: $chan");
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
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{owner}." ".$tu);
		serv_notice("chanserv", $tu, "You have been OWNER'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "OWNER", $sargv[2]." in ".$chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: OWNER: $sargv[2] in $chan");
	}
}

sub svs_cs_deowner {
        my ($user, @sargv) = @_;

        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this command.");
                return;
        }
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: DEOWNER <#channel> [user]");
                return;
        }
        my $acc = uidInfo($user, 9);
        my $chan = $sargv[1];
        if (!is_registered(2, $chan)) {
                serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
                return;
        }
        if (!has_flag($acc, $chan, 'q')) {
                serv_notice("chanserv", $user, "Permission denied.");
                return;
	}
        if (!defined($sargv[2])) {
                if (!ison($user, $chan)) {
                        serv_notice("chanserv", $user, "You are not in \002$chan\002.");
                        return;
                }
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{owner}." ".$user);
                svsilog("chanserv", $user, "DEOWNER", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEOWNER: $chan");
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
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{owner}." ".$tu);
                serv_notice("chanserv", $tu, "You have been DEOWNER'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
                svsilog("chanserv", $user, "DEOWNER", $sargv[2]." in ".$chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEOWNER: $sargv[2] in $chan");
        }
}

