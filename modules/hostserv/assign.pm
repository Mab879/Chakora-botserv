# hostserv/assign by The Chakora Project. Allows assigning and unassigning of vHosts.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("hostserv/assign", "The Chakora Project", "0.1", \&init_hs_assign, \&void_hs_assign, "all");

sub init_hs_assign {
	cmd_add("hostserv/assign", "Assign vHosts (virtual hosts).", "ASSIGN will allow you to assign a vHost to a user, this\nvHost will replace their current hostmask as well as\nreplace it everytime they identify until it is unassigned.\n[T]\nSyntax: ASSIGN <account> <vhost>", \&svs_hs_assign);
	cmd_add("hostserv/unassign", "Unassign vHosts (virtual hosts).", "UNASSIGN will allow you to unassign a vHost, preventing\nit from becoming the user's displayed host any longer.\n[T]\nSyntax: UNASSIGN <account>", \&svs_hs_unassign);
}

sub void_hs_assign {
	delete_sub 'init_hs_assign';
	cmd_del("hostserv/assign");
	cmd_del("hostserv/unassign");
	delete_sub 'svs_hs_assign';
	delete_sub 'svs_hs_unassign';
	delete_sub 'void_hs_assign';
}

sub svs_hs_assign {
	my ($user, @sargv) = @_;
	
	if (!uidInfo($user, 9)) {
		serv_notice("hostserv", $user, "You must be logged in to perform this operation.");
		return;
	}
	if (!has_spower($user, 'hostserv:assign')) {
		serv_notice("hostserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[1]) or !defined($sargv[2])) {
		serv_notice("hostserv", $user, "Not enough parameters. Syntax: ASSIGN <account> <vhost>");
		return;
	}
	if (!defined $Chakora::DB_account{lc($sargv[1])}) {
		serv_notice("hostserv", $user, "Account \002$sargv[1]\002 is not registered.");
		return;
	}
	my $account = $Chakora::DB_account{lc($sargv[1])}{name};
	
	metadata_add(1, $account, 'data:vhost', $sargv[2]);
	if (lc(config('server', 'ircd')) eq 'inspircd12') {
		if ($Chakora::PROTO_SETTINGS{modules} =~ m/m_chghost.so/i) {
			foreach my $key (keys %Chakora::uid) {
				if (lc($Chakora::uid{$key}{account}) eq lc($account)) {
					serv_chghost($key, $sargv[2]);
				}
			}
		}
		else {
			logchan('hostserv', "\002WARNING\002: m_chghost.so is not loaded! Unable to set vHost.");
		}
	}
	else {
		foreach my $key (keys %Chakora::uid) {
			if (lc($Chakora::uid{$key}{account}) eq lc($account)) {
				serv_chghost($key, $sargv[2]);
			}
		}
	}
	serv_notice("hostserv", $user, "vHost for \002$account\002 set to \002$sargv[2]\002.");
	svsilog("hostserv", $user, "ASSIGN", "\002$sargv[2]\002 to \002$account\002");
	svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: ASSIGN: $sargv[2] to $account");
}

sub svs_hs_unassign {
	my ($user, @sargv) = @_;

	if (!uidInfo($user, 9)) {
		serv_notice("hostserv", $user, "You must be logged in to perform this operation.");
		return;
	}
	if (!has_spower($user, 'hostserv:assign')) {
		serv_notice("hostserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("hostserv", $user, "Not enough parameters. Syntax: UNASSIGN <account>");
		return;
	}
	if (!defined $Chakora::DB_account{lc($sargv[1])}) {
		serv_notice("hostserv", $user, "Account \002$sargv[1]\002 is not registered.");
		return;
	}
	my $account = $Chakora::DB_account{lc($sargv[1])}{name};
	if (!metadata(1, $account, 'data:vhost')) {
		serv_notice("hostserv", $user, "Account \002$account\002 currently has no vHost.");
		return;
	}
	
	metadata_del(1, $account, 'data:vhost');
	if (lc(config('server', 'ircd')) eq 'inspircd12') {
		if ($Chakora::PROTO_SETTINGS{modules} =~ m/m_chghost.so/i) {
			foreach my $key (keys %Chakora::uid) {
				if (lc($Chakora::uid{$key}{account}) eq lc($account)) {
					serv_chghost($key, uidInfo($key, 3));
				}
			}
		}
		else {
			logchan('hostserv', "\002WARNING\002: m_chghost.so is not loaded! Unable to remove vHost.");
		}
	}
	else {
		foreach my $key (keys %Chakora::uid) {
			if (lc($Chakora::uid{$key}{account}) eq lc($account)) {
				serv_chghost($key, uidInfo($key, 3));
			}
		}
	}
	
	serv_notice("hostserv", $user, "vHost for \002$account\002 deleted.");
	svsilog("hostserv", $user, "UNASSIGN", $account);
	svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: UNASSIGN: $account");
}
