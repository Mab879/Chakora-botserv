# chanserv/kick by The Chakora Project. Adds a KICK command to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/kick", "The Chakora Project", "1.0", \&init_cs_kick, \&void_cs_kick, "all");

sub init_cs_kick {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/kick", "Kicks a user from a given channel", "KICK allows you to kick a user from \nyour channel or any other channel you have \nthe +k flag in. \n[T]\nSyntax: KICK <#channel> <nickname> [reason]", \&svs_cs_kick);

	if (!flag_exists("k")) {
		flaglist_add("k", "Allows the use of the KICK,BAN,and KICKBAN commands");
	}
}

sub void_cs_kick {
	delete_sub 'init_cs_kick';
	delete_sub 'svs_cs_kick';
	cmd_del("chanserv/kick");
       delete_sub 'void_cs_kick';
}

sub svs_cs_kick {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this operation.");
		return;
	}


	if (!defined($sargv[1]) or !defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: KICK <#channel> <nickname> [reason]");
		return;
	}

	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}


	my $tu = nickUID($sargv[2]);
	my $nick = uidInfo($tu, 1);

	if (!has_flag(uidInfo($user, 9), $sargv[1], "k")) {
		serv_notice("chanserv", $user, "Permission denied");
		return;
	}

	if (!$tu) {
		serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
		return;
	}
	if (!ison($tu, $sargv[1])) {
		serv_notice("chanserv", $user, "\002$nick\002 is not on \002$sargv[1]\002.");
		return;
	}

	if (!defined($sargv[3])) {
		serv_kick("chanserv", $sargv[1], $tu, "KICK command used by ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4));
		event_kick("chanserv", $sargv[1], $tu, "KICK command used by ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4));

		svsilog("chanserv", $user, "KICK", $nick." from ".$sargv[1]." (No Reason Specified)");
		svsflog('commands', uidInfo($user, 1).": ChanServ: KICK: $nick from $sargv[1] (No Reason Specified)");
	}
	else
	{
		my ($i);
		my $vars = $sargv[3];
		for (my $i = 4; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }
		
		serv_kick("chanserv", $sargv[1], $tu, "(".uidInfo($user, 1).") ".$vars);
		event_kick("chanserv", $sargv[1], $tu, "(".uidInfo($user, 1).") ".$vars);

		svsilog("chanserv", $user, "KICK", $nick." from ".$sargv[1]." (".$vars.")");
		svsflog('commands', $nick.": ChanServ: KICK: $nick from $sargv[1] ($vars)");
	}


}

1;