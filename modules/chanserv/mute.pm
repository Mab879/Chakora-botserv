# chanserv/mute by The Chakora Project. Adds an MUTE/UNMUTE command to ChanServ allowing one to (un)mute themselves or another user.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/mute", "The Chakora Project", "0.1", \&init_cs_mute, \&void_cs_mute, "all");

sub init_cs_mute {
	if (!module_exists("chanserv/main")) {
		if ($Chakora::synced) { logchan('operserv', "\002!!!\002 chanserv/mute is of no use without chanserv/main; unloading."); }
		svsflog("chakora", "MODULES: chanserv/mute: Module is of no use without chanserv/main; unloading.");
		print "MODULES: chanserv/mute: Module is of no use without chanserv/main; unloading.\n";
		return 0;
	}
	cmd_add("chanserv/mute", "Mutes you or another user on a channel.", "MUTE will allow you to either mute yourself\nor another user in a channel that you have\nthe +M flag in.\nSyntax: MUTE <#channel> [user]", \&svs_cs_mute);
	cmd_add("chanserv/unmute", "Unmutes you or another user on a channel.", "UNMUTE will allow you to either unmute\nyourself or another user in a channel\nthat you have the +M flag in.\nSyntax: UNMUTE <#channel> [user]", \&svs_cs_unmute);
    if (!flag_exists("M")) {
		flaglist_add("M", "Allows the use of the MUTE/UNMUTE command");
	}
}

sub void_cs_mute {
	delete_sub 'init_cs_mute';
	delete_sub 'svs_cs_mute';
	delete_sub 'svs_cs_unmute';
	cmd_del("chanserv/mute");
	cmd_del("chanserv/unmute");
	flaglist_del("M");
	delete_sub 'void_cs_mute';
}

sub svs_cs_mute {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: MUTE <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'M')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[2])) {
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{mute}."*!*@".uidInfo($user, 3));
		svsilog("chanserv", $user, "MUTE", "\002$chan\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: MUTE: $chan");
	}
	else {
		my $tu = nickUID($sargv[2]);
		if (!$tu) {
			serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
			return;
		}
		serv_mode("chanserv", $chan, "+".$Chakora::PROTO_SETTINGS{mute}."*!*@".uidInfo($tu, 3));
		svsilog("chanserv", $user, "MUTE", "\002".$sargv[2]."\002 in \002".$chan."\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: MUTE: $sargv[2] in $chan");
	}
}

sub svs_cs_unmute {
        my ($user, @sargv) = @_;
        return;

        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this command.");
                return;
        }
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: UNMUTE <#channel> [user]");
                return;
        }
        my $acc = uidInfo($user, 9);
        my $chan = $sargv[1];
        if (!is_registered(2, $chan)) {
                serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
                return;
        }
        if (!has_flag($acc, $chan, 'M')) {
                serv_notice("chanserv", $user, "Permission denied.");
                return;
	}
        if (!defined($sargv[2])) {
                if (lc(config('server', 'ircd')) eq 'inspircd') {
                        serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{mute}.":*@".uidInfo($user, 3));
                }
                else {
                        serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{mute}." *@".uidInfo($user, 3));
                }
                svsilog("chanserv", $user, "UNMUTE", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: UNMUTE: $chan");
        }
        else {
                my $tu = nickUID($sargv[2]);
                if (!$tu) {
                        serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
                        return;
                }
                if (lc(config('server', 'ircd')) eq 'inspircd') {
                        serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{mute}.":*@".uidInfo($tu, 3));
                }
                else {
                        serv_mode("chanserv", $chan, "-".$Chakora::PROTO_SETTINGS{mute}." *@".uidInfo($tu, 3));
                }
                svsilog("chanserv", $user, "UNMUTE", $sargv[2]." in ".$chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: UNMUTE: $sargv[2] in $chan");
        }
}

