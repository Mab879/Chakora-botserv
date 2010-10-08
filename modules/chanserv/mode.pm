# chanserv/mode by The Chakora Project. Adds a MODE command to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/mode", "Russell Bradford", "1.0", \&init_cs_mode, \&void_cs_mode, "all");

sub init_cs_mode {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/mode", "Set modes on a given channel", "MODE allows you to set modes on\nyour channel or any other channel you have \nthe +s flag in.\n[T]\nIRC Operators have the ability to set modes \non a channel if they \nhave the chanserv::override priveledge. \nThe channel will be noticed when an operator\nover-rides using this command in the channel \n[T]\nSyntax: MODE <channel> [+/- modes]", \&svs_cs_mode);
	fantasy("mode", 1);

	if (!flag_exists("c")) {
		flaglist_add("c", "Allows the use of the MODE command");
	}
}

sub void_cs_mode {
	delete_sub 'init_cs_mode';
	delete_sub 'svs_cs_mode';
	cmd_del("chanserv/mode");
	flaglist_del("c");
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
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: MODE <channel> [+/- modes]");
		return;
	}

	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}


	my ($dele);
	my ($vars);
	my ($i);
       $vars = $sargv[2];
	for ($i = 3; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }
	my @modes = split(//, $sargv[2]);

	if (has_spower($user, 'chanserv:override')) 
	{
		$dele .= 'serv_cmode("chanserv", "'.$sargv[1].'", "'.$vars.'"); ';
		$dele .= '1; ';
		eval($dele);
		if (!has_flag(uidInfo($user, 9), $sargv[1], "c")) {
			svsilog("chanserv", $user, "MODE", $sargv[1]." ".$vars." (over-ride)");
			svsflog('commands', uidInfo($user, 1).": ChanServ: MODE: $sargv[1] $vars  (over-ride)");
			serv_notice("chanserv", $sargv[1], "(OVER-RIDE) ".uidInfo($user, 1)." set modes ".$vars." via ChanServ");
		}
		else
		{
			svsilog("chanserv", $user, "MODE", $sargv[1]." ".$vars);
			svsflog('commands', uidInfo($user, 1).": ChanServ: MODE: $sargv[1] $vars");
		}
		return;
	}
	elsif(!has_spower($user, 'chanserv:override'))
	{
		if (!has_flag(uidInfo($user, 9), $sargv[1], "c")) {
			serv_notice("chanserv", $user, "Permission denied");
			return;
		}
		foreach my $key (@modes) 
		{ 
			if ($key eq 'P') 
			{ 
				serv_notice("chanserv", $user, "Permission Denied - You do not have the required operator privileges to set mode 'P'");
				return;
			}
			if($key eq 'O')
			{
				serv_notice("chanserv", $user, "Permission Denied - You do not have the required operator privileges to set mode 'O'");
				return;
			}
			if(lc(config('server', 'ircd')) eq 'charybdis' and $key eq 'A')
			{
				serv_notice("chanserv", $user, "Permission Denied - You do not have the required operator privileges to set mode 'A'");
				return;
			}
			if(lc(config('server', 'ircd')) eq 'charybdis' and $key eq 'L')
			{
				serv_notice("chanserv", $user, "Permission Denied - You do not have the required operator privileges to set mode 'L'");
				return;
			}
		}
		svsilog("chanserv", $user, "MODE", $sargv[1]." ".$vars);
		svsflog('commands', uidInfo($user, 1).": ChanServ: MODE: $sargv[1] $vars");
		$dele .= 'serv_cmode("chanserv", "'.$sargv[1].'", "'.$vars.'"); ';
		$dele .= '1; ';
		eval($dele) or svsilog("chanserv", $user, "MODE:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." ChanServ: MODE:FAIL: ".$@) and serv_notice("chanserv", $user, "An error occurred. Please report this to an IRCop immediately.");
		return;
	}
}

1;
