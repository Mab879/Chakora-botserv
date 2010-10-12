# operserv/kill by Russell Bradford. Adds KILL to OperServ, which allows users with OperServ Access to kill a user from the network anonymously
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/kill", "Russell Bradford", "1.0", \&init_os_kill, \&void_os_kill);

sub init_os_kill {
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

	my $tu = nickUID($sargv[1]);
	my $nick = uidInfo($tu, 1);
	
	my ($dele);
	if (defined($sargv[2])) {
		my $vars = $sargv[2];
		for (my $i = 3; $i < count(@sargv); $i++) { $vars .= ' '.$sargv[$i]; }  	
		svsilog("operserv", $user, "KILL", "\002".$sargv[1]."\002 (".$vars.")");
		svsflog('commands', uidInfo($user, 1).": OperServ: KILL: $sargv[1] ($vars)");
		$dele .= 'serv_kill(\'operserv\', \''.$tu.'\', \'Killed (OperServ ('.$vars.'))\'); event_kill(\'operserv\', \''.$tu.'\', \'Killed (OperServ ('.$vars.'))\');';
		$dele .= '1; ';
		eval($dele) or svsilog("operserv", $user, "KILL:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." OperServ: KILL:FAIL: ".$@) and serv_notice("operserv", $user, "An error occurred. No user was Killed. Please report this to an IRCop immediately.")
	} 
	else
	{
		svsilog("operserv", $user, "KILL", "\002".$sargv[1]."\002");
		svsflog('commands', uidInfo($user, 1).": OperServ: KILL: $nick (No Reason Specified)");
		$dele .= 'serv_kill(\'operserv\', \''.$tu.'\', \'Killed (OperServ (KILL command used by '.uidInfo($user, 1).'!'.uidInfo($user, 2).'@'.uidInfo($user, 4).'))\'); event_kill(\'operserv\', \''.$tu.'\', \'Killed (OperServ (KILL command used by '.uidInfo($user, 1).'!'.uidInfo($user, 2).'@'.uidInfo($user, 4).'))\');';
		$dele .= '1; ';
		eval($dele) or svsilog("operserv", $user, "KILL:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." OperServ: KILL:FAIL: ".$@) and serv_notice("operserv", $user, "An error occurred. No user was Killed. Please report this to an IRCop immediately.")
	}
}

1;
