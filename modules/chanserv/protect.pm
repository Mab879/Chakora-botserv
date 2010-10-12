# chanserv/protect by The Chakora Project. Adds a PROTECT/DEPROTECT command to ChanServ allowing one to (de)protect themselves or another user.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/protect", "The Chakora Project", "0.1", \&sinit_cs_protect, \&void_cs_protect);

sub sinit_cs_protect {
	if ($Chakora::synced) { init_cs_protect(); }
	else { hook_pds_add(\&init_cs_protect); }
}

sub init_cs_protect {
	if (!defined($Chakora::PROTO_SETTINGS{admin})) {
		svsflog("modules", "Unable to load chanserv/protect, admin prefix not available.");
		if ($Chakora::synced) { logchan("operserv", "\002chanserv/protect\002: Unable to load, this protocol does not support the admin prefix."); }
		module_void("chanserv/protect");
	}
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/protect", "Protects you or another user on a channel.", "PROTECT will allow you to either protect \nyourself or another user in a channel\nthat you have the +a flag in. \n[T]\nSyntax: PROTECT <#channel> [user]", \&svs_cs_protect);
	cmd_add("chanserv/deprotect", "Deprotects you or another user on a channel.", "DEPROTECT will allow you to either\ndeprotect yourself or another user in\na channel that you have the +a flag in. \n[T]\nSyntax: DEPROTECT <#channel> [user]", \&svs_cs_deprotect);
	fantasy("protect", 1);
	fantasy("deprotect", 1);
	if (!flag_exists("a")) {
		flaglist_add("a", "Allows the use of the PROTECT/DEPROTECT command");
	}
}

sub void_cs_protect {
	delete_sub 'sinit_cs_protect';
	delete_sub 'init_cs_protect';
	delete_sub 'svs_cs_protect';
	delete_sub 'svs_cs_deprotect';
	hook_pds_del(\&sinit_cs_protect);
	cmd_del("chanserv/protect");
	cmd_del("chanserv/deprotect");
	flaglist_del("a");
	delete_sub 'void_cs_protect';
}

sub svs_cs_protect {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: PROTECT <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'a')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[2])) {
		if (!ison($user, $chan)) {
			serv_notice("chanserv", $user, "You are not in \002$chan\002.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{admin}." ".$user);
		svsilog("chanserv", $user, "PROTECT", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: PROTECT: $chan");
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
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{admin}." ".$tu);
		serv_notice("chanserv", $tu, "You have been PROTECT'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "PROTECT", $sargv[2]." in ".$chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: PROTECT: $sargv[2] in $chan");
	}
}

sub svs_cs_deprotect {
        my ($user, @sargv) = @_;

        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this command.");
                return;
        }
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: DEPROTECT <#channel> [user]");
                return;
        }
        my $acc = uidInfo($user, 9);
        my $chan = $sargv[1];
        if (!is_registered(2, $chan)) {
                serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
                return;
        }
        if (!has_flag($acc, $chan, 'a')) {
                serv_notice("chanserv", $user, "Permission denied.");
                return;
	}
        if (!defined($sargv[2])) {
                if (!ison($user, $chan)) {
                        serv_notice("chanserv", $user, "You are not in \002$chan\002.");
                        return;
                }
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{admin}." ".$user);
                svsilog("chanserv", $user, "DEPROTECT", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEPROTECT: $chan");
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
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{admin}." ".$tu);
                serv_notice("chanserv", $tu, "You have been DEPROTECT'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
                svsilog("chanserv", $user, "DEPROTECT", $sargv[2]." in ".$chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEPROTECT: $sargv[2] in $chan");
        }
}

