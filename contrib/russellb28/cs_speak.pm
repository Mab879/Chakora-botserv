# chanserv/speak by Russell Bradford. Adds SAY and ACT to ChanServ, which allows users with the 'B' flag to speak through chanserv to a specified channel
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/speak", "Russell Bradford", "1.0", \&init_cs_speak, \&void_cs_speak, "all");

sub init_cs_speak {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/say", "Allows you to speak through ChanServ", "SAY allows you to send messages to\na specified channel through ChanServ \nproviding you have the 'B' flag.\n[T]\nSyntax: SAY <channel> [message]", \&svs_cs_say);
	cmd_add("chanserv/act", "Allows you to speak through ChanServ using Actions", "ACT allows you to send actions to\na specified channel through ChanServ \nproviding you have the 'B' flag.\n[T]\nSyntax: ACT <channel> [message]", \&svs_cs_act);
	if (!flag_exists("B")) {
	        flaglist_add("B", "Allows the use of SAY/ACT Commands");
	}
}

sub void_cs_speak {
	delete_sub 'init_cs_speak';
	delete_sub 'svs_cs_say';
	delete_sub 'svs_cs_act';
	cmd_del("chanserv/say");
	cmd_del("chanserv/act");
	flaglist_del("B");
       delete_sub 'void_cs_speak';
}

sub svs_cs_say {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You are not identified.");
		return;
	}
	
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: SAY <channel> [message]");
		return;
	}

	if (!defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: SAY <channel> [message]");
		return;
	}

	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}

	elsif (!has_flag(uidInfo($user, 9), $sargv[1], "B")) {
		serv_notice("chanserv", $user, "Permission denied");
		return;
	}


	my ($dele);
	my ($vars);
	my ($i);
       $vars = $sargv[2];
	for ($i = 3; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }

	svsilog("chanserv", $user, "SAY", "\002".$sargv[1]."\002 :".$vars);
	svsflog('commands', uidInfo($user, 1).": ChanServ: SAY: $sargv[1] :$vars");
	$dele .= 'serv_privmsg("chanserv", "'.$sargv[1].'", "'.$vars.'"); ';
	$dele .= '1; ';
	eval($dele) or svsilog("chanserv", $user, "SAY:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." ChanServ: SAY:FAIL: ".$@) and serv_notice("chanserv", $user, "An error occurred. Please report this to an IRCop immediately.")
}

sub svs_cs_act {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You are not identified.");
		return;
	}
	
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: ACT <channel> [message]");
		return;
	}

	if (!defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: ACT <channel> [message]");
		return;
	}

	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}

	elsif (!has_flag(uidInfo($user, 9), $sargv[1], "B")) {
		serv_notice("chanserv", $user, "Permission denied");
		return;
	}


	my ($dele);
	my ($vars);
	my ($i);
       $vars = $sargv[2];
	for ($i = 3; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }

	svsilog("chanserv", $user, "ACT", "\002".$sargv[1]."\002 :".$vars);
	svsflog('commands', uidInfo($user, 1).": ChanServ: ACT: $sargv[1] :$vars");
	$dele .= 'serv_privmsg("chanserv", "'.$sargv[1].'", "\001ACTION '.$vars.'\001"); ';
	$dele .= '1; ';
	eval($dele) or svsilog("chanserv", $user, "ACT:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." ChanServ: ACT:FAIL: ".$@) and serv_notice("chanserv", $user, "An error occurred. Please report this to an IRCop immediately.")
}

1;
