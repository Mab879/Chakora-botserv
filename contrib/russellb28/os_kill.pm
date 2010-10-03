# operserv/kill by Russell Bradford. Adds KILL to OperServ, which allows users with OperServ Access to kill a user from the network anonymously
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/kill", "Russell Bradford", "1.0", \&init_os_kill, \&void_os_kill, "all");

sub init_os_kill {
       if (!module_exists("operserv/main")) {
		module_load("operserv/main");
       }

	cmd_add("operserv/kill", "Kill a user from the network using OperServ", "Kill a user from the network using operserv \nwith a specific reason. If no reason \nis specified then the user will be killed \nwith a reason that shows your \nnickname.\n[T]\nSyntax: KILL <nickname> [reason]", \&svs_os_kill);
}

sub void_os_kill {
	delete_sub 'init_os_kill';
	delete_sub 'svs_os_kill';
	cmd_del("operserv/kill");
       delete_sub 'void_os_kill';
}

sub svs_os_kill {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("operserv", $user, "Not enough parameters. Syntax: KILL [nickname] <reason>");
		return;
	}
	
	if (!nickUID($sargv[1])) {
		serv_notice("operserv", $user, "Nickname \002$sargv[1]\002 is not online.");
		return;
	}
	
	my ($dele);
	if (defined($sargv[2])) {
		svsilog("operserv", $user, "KILL", $sargv[1], $sargv[2]);
		svsflog('commands', uidInfo($user, 1).": OperServ: KILL: $sargv[1] ($sargv[2])");
		$dele .= 'serv_kill(\'operserv\', \''.$sargv[1].'\', \'Killed (OperServ ('.$sargv[2].'))\'); event_kill(\'operserv\', \''.$sargv[1].'\', \'Killed (OperServ ('.$sargv[2].'))\');';
		$dele .= '1; ';
		eval($dele) or svsilog("operserv", $user, "KILL:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." OperServ: KILL:FAIL: ".$@) and serv_notice("operserv", $user, "An error occurred. No user was Killed. Please report this to an IRCop immediately.")
	} 
	else
	{
		svsilog("operserv", $user, "KILL", $sargv[1]);
		svsflog('commands', uidInfo($user, 1).": OperServ: KILL: $sargv[1] (No Reason Specified)");
		$dele .= 'serv_kill(\'operserv\', \''.$sargv[1].'\', \'Killed (OperServ (KILL command used by '.uidInfo($user, 1).'!'.uidInfo($user, 2).'@'.uidInfo($user, 4).'))\'); event_kill(\'operserv\', \''.$sargv[1].'\', \'Killed (OperServ (KILL command used by '.uidInfo($user, 1).'!'.uidInfo($user, 2).'@'.uidInfo($user, 4).'))\');';
		$dele .= '1; ';
		eval($dele) or svsilog("operserv", $user, "KILL:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." OperServ: KILL:FAIL: ".$@) and serv_notice("operserv", $user, "An error occurred. No user was Killed. Please report this to an IRCop immediately.")
	}
}

1;