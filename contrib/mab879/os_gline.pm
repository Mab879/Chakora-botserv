# operserv/gline by Matthew Burket. Allows an IRC operator to gline a user.
#
# Copyright (c) 2010 Matthew Burket. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE
use strict;
use warnings;

#Start the module
	module_init("operserv/gline", "Mathew Burket", "0.1", \&init_os_gline, \&void_os_gline);

sub init_os_gline {
	cmd_add("operserv/gline", "Set a network ban..", "GLINE allows an IRC operator to issue a Network Ban for a user./n With a reason your nick is hidden with a reason./n With out one your nick will show. [T]\nSyntax: GLINE <nickane/ ident / hostname> [duration] [reason] " \&svs_os_gline);
	cmd_add("operserv/kline","Sets a global ban.", "KLINE allows an IRC operator", "to issue a Network Ban for a user./n With a reason your nick is hidden with a reason./n With out one your nick will show. [T]\nSyntax: KLINE <nickane/ ident / hostname> [duration] [reason]" \&svs_os_kline); 
	cmd_add("operserv/netban","Sets a global ban", "NETBAN allows an IRC operator to issue a Network Ban for a user./n With a reason your nick is hidden with a reason./n With out one your nick will show. [T]\nSyntax: NETBAN <nickane/ ident / hostname> [duration] [reason] " \&svs_os_netban);
	
}

sub void_os_gline {
	sub_delete "init_os_gline";
	sub_delete "init_os_gline";
	sub_delete "svs_os_gline";
	sub_delete "svs_os_kline";
	sub delete "svs_os_netban"
}

sub svs_os_gline {
	my ($user, @sargv) = @_;
if (has_spower($user, 'operserv:gline'))	(
	if (!defined($sargv[1])) (
		serv_notice("operserv", $user, "Not enough parameters. Syntax: GLINE <nick / ident / hostname> [durtion] [reason]");
		return;
		)
	if (!defined($sargv[2])) {
		serv_notice("operserv", $user "Not enough paramenters. Syntax: GLINE <nick / ident / hostname> [duriton] [reason]");
		return;
	}
	if (!defined($sargv[3])) {
		net_ban($sargv $user );
		svsilog("operserv", $user "GLINE:" $sargv);
		serv_notice("operserv", $user "PLEASE NOTE: That your nick  was the  reason for this Network Ban./n Added gline:" $sargv);
		return;
	}
	if (defined($sargv[3]))  {
		net_ban($sargv);
		svsilog("operserv", $user GLINE: $sargv);
		serv_ntoice("operserv", $user, $sargv); 
		
	
		)
	}
	else  {
		serv_notice("operserv", $user "You do not have access to the gline command!/n YOUR ACTION HAS BEEN LOGGED!");
		svsilog("operserv", $user, "NetBan: $sargv");
	}
		
	}

sub svs_os_kline {
	my ($user, @sargv) = @_;
if (has_spower($user, 'operserv:gline'))	(
	if (!defined($sargv[1])) (
		serv_notice("operserv", $user, "Not enough parameters. Syntax: KLINE <nick / ident / hostname> [durtion] [reason]");
		return;
		)
	if (!defined($sargv[2])) {
		serv_notice("operserv", $user "Not enough paramenters. Syntax: KLINE <nick / ident / hostname> [duriton] [reason]");
		return;
	}
	if (!defined($sargv[3])) {
		net_ban($sargv $user );
		svsilog("operserv", $user "KLINE:" $sargv);
		serv_notice("operserv", $user "PLEASE NOTE: That your nick  was the  reason for this Network Ban./n Added kline:" $sargv);
		return;
	}
	if (defined($sargv[3])) 
		net_ban($sargv);
		svsilog("operserv", $user KLINE: $sargv);
		serv_ntoice("operserv", $user, $sargv); 
		
	
		)
	else  {
		serv_notice("operserv", $user "You do not have access to the Kline command!/n YOUR ACTION HAS BEEN LOGGED!");
		svsilog("operserv", $user, "Kline: $sargv");
	}
sub svs_os_netban {
	my ($user, @sargv) = @_;
if (has_spower($user, 'operserv:gline'))	(
	if (!defined($sargv[1])) (
		serv_notice("operserv", $user, "Not enough parameters. Syntax: NETBAN <nick / ident / hostname> [durtion] [reason]");
		return;
		)
	if (!defined($sargv[2])) {
		serv_notice("operserv", $user "Not enough paramenters. Syntax: NETBAN <nick / ident / hostname> [duriton] [reason]");
		return;
	}
	if (!defined($sargv[3])) {
		net_ban($sargv $user );
		svsilog("operserv", $user "KLINE:" $sargv);
		serv_notice("operserv", $user "PLEASE NOTE: That your nick  was the  reason for this Network Ban./n Added a Network Ban for:" $sargv);
		return;
	}
	if (defined($sargv[3])) 
		net_ban($sargv);
		svsilog("operserv", $user NETBAN: $sargv);
		serv_ntoice("operserv", $user, $sargv); 
		
	
		)
	else  {
		serv_notice("operserv", $user "You do not have access to the Netban  command!/n YOUR ACTION HAS BEEN LOGGED!");
		svsilog("operserv", $user, "NETBAN: $sargv");
	}		
}
