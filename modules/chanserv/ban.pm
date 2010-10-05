# chanserv/ban by The Chakora Project. Adds a BAN command to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/ban", "The Chakora Project", "1.0", \&init_cs_ban, \&void_cs_ban, "all");

sub init_cs_ban {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/ban", "Bans a user from a given channel", "BAN allows you to place a ban on a user in \nyour channel or any other channel you have \nthe +k flag in. \n[T]\nSyntax: BAN <#channel> <nickname>", \&svs_cs_ban);
	cmd_add("chanserv/unban", "Bans a user from a given channel", "UNBAN allows you to remove a ban placed on a \nuser in your channel or any other channel \nyou have the +k flag in. \n[T]\nSyntax: UNBAN <#channel> <nickname>", \&svs_cs_unban);

	if (!flag_exists("k")) {
		flaglist_add("k", "Allows the use of the KICK,BAN,and KICKBAN commands");
	}
}

sub void_cs_ban {
	delete_sub 'init_cs_ban';
	delete_sub 'svs_cs_ban';
	delete_sub 'svs_cs_unban';
	cmd_del("chanserv/ban");
	cmd_del("chanserv/unban");
       delete_sub 'void_cs_ban';
}

sub svs_cs_ban {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this operation.");
		return;
	}


	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: BAN <#channel> [nickname]");
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
		svsilog("chanserv", $user, "BAN", "\002$sargv[1]\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: BAN: $sargv[1]");
	}
	else
	{
		my $tu = nickUID($sargv[2]);
		my $nick = uidInfo($tu, 1);

		if (!$tu) {
			serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
			return;
		}
		serv_mode("chanserv", $sargv[1], "+b *!*@".uidInfo($tu, 4));
		svsilog("chanserv", $user, "BAN", "\002".$nick."\002 in \002".$sargv[1]."\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: BAN: $nick in $sargv[1]");
	}
}

sub svs_cs_unban {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this operation.");
		return;
	}


	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: UNBAN <#channel> [nickname]");
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
		serv_mode("chanserv", $sargv[1], "-b *!*@".uidInfo($user, 4));
		svsilog("chanserv", $user, "UNBAN", "\002$sargv[1]\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: UNBAN: $sargv[1]");
	}
	else
	{
		my $tu = nickUID($sargv[2]);
		my $nick = uidInfo($tu, 1);

		if (!$tu) {
			serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
			return;
		}
		serv_mode("chanserv", $sargv[1], "-b *!*@".uidInfo($tu, 4));
		svsilog("chanserv", $user, "UNBAN", "\002".$nick."\002 in \002".$sargv[1]."\002");
		svsflog('commands', uidInfo($user, 1).": ChanServ: UNBAN: $nick in $sargv[1]");
	}
}



1;
