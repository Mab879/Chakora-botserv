# chanserv/voice by The Chakora Project. Adds an VOICE/DEVOICE command to ChanServ allowing one to (de)voice themselves or another user.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/voice", "The Chakora Project", "0.1", \&init_cs_voice, \&void_cs_voice, "all");

sub init_cs_voice {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/voice", "Voices you or another user on a channel.", "VOICE will allow you to either voice \nyourself or another user in a channel\nthat you have the +v flag in. \n[T]\nSyntax: VOICE <#channel> [user]", \&svs_cs_voice);
	cmd_add("chanserv/devoice", "Devoices you or another user on a channel.", "DEVOICE will allow you to either\ndevoice yourself or another user in\na channel that you have the +v flag in. \n[T]\nSyntax: DEVOICE <#channel> [user]", \&svs_cs_devoice);
        if (!flag_exists("v")) {
                flaglist_add("v", "Allows the use of the VOICE/DEVOICE command");
        }

}

sub void_cs_voice {
	delete_sub 'init_cs_voice';
	delete_sub 'svs_cs_voice';
	delete_sub 'svs_cs_devoice';
	cmd_del("chanserv/voice");
	cmd_del("chanserv/devoice");
	flaglist_del("v");
	delete_sub 'void_cs_voice';
}

sub svs_cs_voice {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: VOICE <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'v')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[2])) {
		if (!ison($user, $chan)) {
			serv_notice("chanserv", $user, "You are not in \002$chan\002.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{voice}." ".$user);
		svsilog("chanserv", $user, "VOICE", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: VOICE: $chan");
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
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{voice}." ".$tu);
		serv_notice("chanserv", $tu, "You have been VOICEd in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "VOICE", $sargv[2]." in ".$chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: VOICE: $sargv[2] in $chan");
	}
}

sub svs_cs_devoice {
        my ($user, @sargv) = @_;

        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this command.");
                return;
        }
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: DEVOICE <#channel> [user]");
                return;
        }
        my $acc = uidInfo($user, 9);
        my $chan = $sargv[1];
        if (!is_registered(2, $chan)) {
                serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
                return;
        }
        if (!has_flag($acc, $chan, 'v')) {
                serv_notice("chanserv", $user, "Permission denied.");
                return;
	}
        if (!defined($sargv[2])) {
                if (!ison($user, $chan)) {
                        serv_notice("chanserv", $user, "You are not in \002$chan\002.");
                        return;
                }
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{voice}." ".$user);
                svsilog("chanserv", $user, "DEVOICE", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEVOICE: $chan");
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
                serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{voice}." ".$tu);
                serv_notice("chanserv", $tu, "You have been DEVOICEd in \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
                svsilog("chanserv", $user, "DEVOICE", $sargv[2]." in ".$chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: DEVOICE: $sargv[2] in $chan");
        }
}

