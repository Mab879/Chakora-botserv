# chanserv/invite by The Chakora Project. Adds an INVITE command to ChanServ for inviting themselves or others.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/invite", "The Chakora Project", "0.1", \&init_cs_invite, \&void_cs_invite);

sub init_cs_invite {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/invite", "Invites you or another user to a channel.", "INVITE will allow you to either invite yourself\nor another user to a channel.  This can\nbe useful for invite-only channels with\nno other means of accessing them.\n[T]\nSyntax: INVITE <#channel> [user]", \&svs_cs_invite);
	fantasy("invite", 1);
        if (!flag_exists("i")) {
                flaglist_add("i", "Allows the use of the INVITE command");
        }

}

sub void_cs_invite {
	delete_sub 'init_cs_invite';
	delete_sub 'svs_cs_invite';
	cmd_del("chanserv/invite");
	flaglist_del("i");
	delete_sub 'void_cs_invite';
}

sub svs_cs_invite {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: INVITE <#channel> [user]");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'i')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined $Chakora::channel{lc($chan)}{'members'}) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is currently empty.");
		return;
	}
	
	if (!defined($sargv[2])) {
		if (ison($user, $chan)) {
			serv_notice("chanserv", $user, "You are already on \002$chan\002.");
			return;
		}
		serv_invite("chanserv", $user, $Chakora::DB_chan{lc($chan)}{name});
		serv_notice("chanserv", $user, "You have been invited to \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "INVITE", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: INVITE: $chan");
	}
	else {
		my $tu = nickUID($sargv[2]);
		if (!$tu) {
			serv_notice("chanserv", $user, "User \002$sargv[2]\002 is not online.");
			return;
		}
		if (ison($tu, $chan)) {
			serv_notice("chanserv", $user, "\002$sargv[2]\002 is already on \002$chan\002.");
			return;
		}
		serv_invite("chanserv", $tu, $Chakora::DB_chan{lc($chan)}{name});
		serv_notice("chanserv", $tu, "\002".uidInfo($user, 1)."\002 invites you to join channel \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		serv_notice("chanserv", $user, "\002$sargv[2]\002 has been invited to join channel \002".$Chakora::DB_chan{lc($chan)}{name}."\002.");
		svsilog("chanserv", $user, "INVITE", $sargv[2]." to ".$chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: INVITE: $sargv[2] to $chan");
	}
}
