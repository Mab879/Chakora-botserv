# chanserv/invite by The Chakora Project. Adds an INVITE command to ChanServ for inviting themselves or others.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/clear", "The Chakora Project", "0.1", \&init_cs_clear, \&void_cs_clear, "all");

sub init_cs_clear {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/clear", "Clears certain channel aspects.", "CLEAR will allow you to clear certain things\nCLEAR USERS for one, can be useful if you are closing your channel.\n[T]\nSyntax: CLEAR <users|flags|bans> <#channel>", \&svs_cs_clear);
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
	
	if (!uidInfo($user, 9)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this command.");
		return;
	}
	if (!defined($sargv[1]) or !defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: CLEAR <users|flags|bans> <#channel>");
		return;
	}
	my $acc = uidInfo($user, 9);
	my $chan = $sargv[2];
	if (!is_registered(2, $chan)) {
		serv_notice("chanserv", $user, "Channel \002$chan\002 is not registered.");
		return;
	}
	if (!has_flag($acc, $chan, 'C')) {
		serv_notice("chanserv", $user, "Permission denied.");
		return;
	}
	if (!defined $Chakora::channel{lc($chan)}{'members'}) {
		if (lc($sargv[1]) eq 'users' or lc($sargv[1]) eq 'bans') {
			serv_notice("chanserv", $user, "Channel \002$chan\002 is currently empty.");
			return;
		}
	}
	
	if (lc($sargv[1]) eq 'users') {
		cs_clearusers($chan, $user);
		svsilog("chanserv", $user, "CLEAR:USERS", $chan);
		svsflog('commands', uidInfo($user, 1).": ChanServ: CLEAR: USERS: $chan");
	}
}


sub cs_clearusers {
	my ($c, $u) = @_;
	my @cusers = split(' ', $Chakora::channel{lc($c)}{'members'});
	foreach my $user (@cusers) {
		serv_kick("chanserv", $c, $user, "CLEAR USERS by ".uidInfo($u, 1));
	}
}
