# chanserv/clear by The Chakora Project. Adds a CLEAR command to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/clear", "The Chakora Project", "0.1", \&init_cs_clear, \&void_cs_clear);

sub init_cs_clear {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/clear", "Clears certain channel aspects.", "CLEAR will allow you to clear certain things\nCLEAR USERS for one, can be useful if you are closing your channel.\n[T]\nSyntax: CLEAR <#channel> <users|flags|bans>", \&svs_cs_clear);
	fantasy("clear", 1);
        if (!flag_exists("C")) {
                flaglist_add("C", "Allows the use of the CLEAR command");
        }

}

sub void_cs_clear {
	delete_sub 'init_cs_clear';
	delete_sub 'svs_cs_clear';
	delete_sub 'cs_clearusers';
	cmd_del("chanserv/clear");
	flaglist_del("C");
	delete_sub 'void_cs_clear';
}

sub svs_cs_clear {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1]) or !defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: CLEAR <#channel> <users|flags|bans>");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[1];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'C')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined $Chakora::channel{lc($chan)}{'members'}) {
		if (lc($sargv[2]) eq 'users' or lc($sargv[2]) eq 'bans') {
			serv_notice("chanserv", $user, "Channel \002$chan\002 is currently empty.");
			return;
		}
	}
	
	if (lc($sargv[2]) eq 'users') {
		cs_clearusers($chan, $user);
		svsilog("chanserv", $user, "CLEAR:USERS", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: CLEAR: USERS: $chan");
	}

        if (lc($sargv[2]) eq 'flags') {
                cs_clearflags($chan, $user);
                svsilog("chanserv", $user, "CLEAR:FLAGS", $chan);
                svsflog('commands', uidInfo($user, 1).": ChanServ: CLEAR: FLAGS: $chan");
        }

}


sub cs_clearusers {
	my ($c, $u) = @_;
	my @cusers = split(' ', $Chakora::channel{lc($c)}{'members'});
	foreach my $user (@cusers) {
		serv_kick("chanserv", $c, $user, "CLEAR USERS by ".uidInfo($u, 1));
	}
}

sub cs_clearflags {
	my ($c, $u) = @_;
	foreach my $key (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$key}{chan}) eq lc($c)) {
			if(lc($Chakora::DB_chan{$c}{founder}) ne lc($Chakora::DB_chanflags{$key}{account})) {
				delete $Chakora::DB_chanflags{$key};
			}
		}
	}
}
