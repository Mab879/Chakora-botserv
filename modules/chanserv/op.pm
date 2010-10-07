# chanserv/op by The Chakora Project. Adds an OP/DEOP command to ChanServ allowing one to (de)op themselves or another user.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/op", "The Chakora Project", "0.1", \&init_cs_op, \&void_cs_op, "all");

sub init_cs_op {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/op", "Ops you or another user on a channel.", "OP will allow you to either op yourself\nor another user in a channel that you\nhave the +o flag in.\n[T]\nSyntax: OP <#channel> [user]", \&svs_cs_op);
	cmd_add("chanserv/deop", "Deops you or another user on a channel.", "DEOP will allow you to either deop\nyourself or another user in a channel\nthat you have the +o flag in. \n[T]\nSyntax: DEOP <#channel> [user]", \&svs_cs_deop);
	fantasy("op", 1);
	fantasy("deop", 1);
        if (!flag_exists("o")) {
                flaglist_add("o", "Allows the use of the OP/DEOP command");
        }

}

sub void_cs_op {
	delete_sub 'init_cs_op';
	delete_sub 'svs_cs_op';
	delete_sub 'svs_cs_deop';
	cmd_del("chanserv/op");
	cmd_del("chanserv/deop");
	flaglist_del("o");
	delete_sub 'void_cs_op';
}

sub svs_cs_op {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: OP <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'o')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[2])) {
		if (!ison($user, $chan)) {
			serv_notice("chanserv", $user, "You are not in \002$chan\002.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{op}." ".$user);
		svsilog("chanserv", $user, "OP", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: OP: $chan");
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
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{op}." ".$tu);
		serv_notice("chanserv", $tu, "You have been OP'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "OP", $sargv[2]." in ".$chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: OP: $sargv[2] in $chan");
	}
}

sub svs_cs_deop {
        my ($user, @sargv) = @_;

        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this command.");
                return;
        }
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: DEOP <#channel> [user]");
                return;
        }
        my $acc = uidInfo($user, 9);
        my $chan = $sargv[1];
        if (!is_registered(2, $chan)) {
                serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
                return;
        }
        if (!has_flag($acc, $chan, 'o')) {
                serv_notice("chanserv", $user, "Permission denied.");
                return;
	}
        if (!defined($sargv[2])) {
                if (!ison($user, $chan)) {
                        serv_notice("chanserv", $user, "You are not in \002$chan\002.");
                        return;
                }
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{op}." ".$user);
                svsilog("chanserv", $user, "DEOP", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEOP: $chan");
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
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{op}." ".$tu);
                serv_notice("chanserv", $tu, "You have been DEOP'ed in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
                svsilog("chanserv", $user, "DEOP", $sargv[2]." in ".$chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEOP: $sargv[2] in $chan");
        }
}

