# chanserv/kickban by The Chakora Project. Adds a KICKBAN command to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/kickban", "The Chakora Project", "1.0", \&init_cs_kickban, \&void_cs_kickban, "all");

sub init_cs_kickban {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/kickban", "Kicks and Bans a user from a given channel", "KICKBAN allows you to place a ban on a user in \nyour channel or any other channel and kick \nthem at the same time providing you have \nthe +k flag. \n[T]\nSyntax: KICKBAN <#channel> [nickname] [reason]", \&svs_cs_kickban);

	if (!flag_exists("k")) {
		flaglist_add("k", "Allows the use of the KICK,BAN,and KICKBAN commands");
	}
}

sub void_cs_kickban {
	delete_sub 'init_cs_kickban';
	delete_sub 'svs_cs_kickban';
	cmd_del("chanserv/kickban");
       delete_sub 'void_cs_kickban';
}

sub svs_cs_kickban {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this operation.");
		return;
	}


	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: KICKBAN <#channel> [nickname] [reason]");
		return;
	}

	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}

	if (!has_flag(uidInfo($user, 9), $sargv[1], "k")) {
		serv_notice("chanserv", $user, "Permission denied");
		return;
	}

	if (!defined($sargv[2])) {
		serv_mode("chanserv", $sargv[1], "+b *!*@".uidInfo($user, 4));
		serv_kick("chanserv", $sargv[1], $user, "KICKBAN command used by ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4));
		event_kick("chanserv", $sargv[1], $user, "KICKBAN command used by ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4));
		svsilog("chanserv", $user, "KICKBAN", "\002$sargv[1]\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: KICKBAN: $sargv[1]");
	}
	else
	{
		my $tu = nickUID($sargv[2]);
		my $nick = uidInfo($tu, 1);

		if (!$tu) {
			serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
			return;
		}
		if (!ison($tu, $sargv[1])) {
			serv_notice("chanserv", $user, "\002$nick\002 is not on \002$sargv[1]\002.");
			return;
		}
		if (!defined($sargv[3])) {
			serv_mode("chanserv", $sargv[1], "+b *!*@".uidInfo($tu, 4));
			serv_kick("chanserv", $sargv[1], $tu, "KICKBAN command used by ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4));
			event_kick("chanserv", $sargv[1], $tu, "KICKBAN command used by ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4));
			svsilog("chanserv", $user, "KICKBAN", "\002".$nick."\002 in \002".$sargv[1]."\002");
			svsflog('commands', uidInfo($user, 1).": ChanServ: KICKBAN: $nick in $sargv[1]");
		}
		else
		{
			my $vars = $sargv[3];
			for (my $i = 4; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }

			serv_mode("chanserv", $sargv[1], "+b *!*@".uidInfo($tu, 4));
			serv_kick("chanserv", $sargv[1], $tu, "(".uidInfo($user, 1).") ".$vars);
			event_kick("chanserv", $sargv[1], $tu, "(".uidInfo($user, 1).") ".$vars);
			svsilog("chanserv", $user, "KICKBAN", "\002".$nick."\002 in \002".$sargv[1]."\002 (".$vars.")");
			svsflog('commands', uidInfo($user, 1).": ChanServ: KICKBAN: $nick in $sargv[1] ($vars)");
		}
	}
}

1;
