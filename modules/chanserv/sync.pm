# chanserv/sync by The Chakora Project. Adds a SYNC command to Chakora, for syncing a channel with its access list.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/sync", "The Chakora Project", "0.1", \&init_cs_sync, \&void_cs_sync, "all");

sub init_cs_sync {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/sync", "Syncs a channel with its access list.", "NO_HELP_ENTRY", \&svs_cs_sync);
	if (!flag_exists("S")) { 
		flaglist_add("S", "Allows the use of the SYNC command");
	}
}

sub void_cs_sync {
	delete_sub 'init_cs_sync';
	delete_sub 'svs_cs_sync';
	cmd_del("chanserv/sync");
	flaglist_del("S");
	delete_sub 'void_cs_sync';
}

sub svs_cs_sync {
	my ($user, @sargv) = @_;
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	my $account = uidInfo($user, 9);
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: SYNC <#channel>");
		return;
	}
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 isn't registered.");
		return;
	}	
	if (!has_flag($account, $chan, "S")) {
		serv_notice("chanserv", $user, "You are not authorized to perform this command.");
		return;
	} 
	else {
		my @cmems = split(' ', $Chakora::channel{lc($chan)}{'members'});
 		foreach my $user (@cmems) {
			apply_status($user, $chan);
		}
		serv_notice("chanserv", $user, "Channel synced with access list.");
	}
}
