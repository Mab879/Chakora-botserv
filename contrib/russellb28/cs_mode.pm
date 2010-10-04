# chanserv/mode by Russell Bradford. Adds MODE to ChanServ, which allows users with the 's' flag to set modes on the channel via ChanServ
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/mode", "Russell Bradford", "1.0", \&init_cs_mode, \&void_cs_mode, "all");

sub init_cs_mode {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/mode", "Set modes on a given channel", "MODE allows you to set modes on\na specified channel through ChanServ \nproviding you have the 's' flag.\n[T]\nSyntax: MODE <channel> [+/- modes]", \&svs_cs_mode);

	if (!flag_exists("s")) {
	        svsflog("modules", "Unable to load chanserv/mode, Flag +s is not supported!");
		 module_void("chanserv/mode");
	}
}

sub void_cs_mode {
	delete_sub 'init_cs_mode';
	delete_sub 'svs_cs_mode';
	cmd_del("chanserv/mode");
       delete_sub 'void_cs_mode';
}

sub svs_cs_mode {
	my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You are not identified.");
		return;
	}
	
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: MODE <channel> [+/- modes]");
		return;
	}

	if (!defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: SAY <channel> [+/- modes]");
		return;
	}

	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}

	elsif (!has_flag(uidInfo($user, 9), $sargv[1], "s")) {
		serv_notice("chanserv", $user, "Permission denied");
		return;
	}


	my ($dele);
	my ($vars);
	my ($i);
       $vars = $sargv[2];
	for ($i = 3; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }

	svsilog("chanserv", $user, "MODE", $sargv[1]." ".$vars);
	svsflog('commands', uidInfo($user, 1).": ChanServ: MODE: $sargv[1] $vars");
	$dele .= 'serv_cmode("chanserv", "'.$sargv[1].'", "'.$vars.'"); ';
	$dele .= '1; ';
	eval($dele) or svsilog("chanserv", $user, "MODE:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." ChanServ: MODE:FAIL: ".$@) and serv_notice("chanserv", $user, "An error occurred. Please report this to an IRCop immediately.")
}

1;