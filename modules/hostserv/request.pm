# HostServ/Request Request a vHost.
#
# Copyright (c) 2011 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warning;

# Starting the module
module_init("hostserv/request", "Franklin IRC Services", "0.1", \&init_hs_request, \&void_hs_request);

sub init_hs_request {
	cmd_add("hostserv/request", "Request vHost (virtual hosts).", "REQUEST will allow you request a vHost./n Syntax: REQUEST <vhost>", \&svs_hs_request);
	cmd_add("hostserv/waiting", "List the vHost currently", "WAITING will list the all of the vHost(s)w waiting to be approved.",/&svs_hs_waiting);
}

sub void_hs_request {
	delete_sub "init_hs_request";
	delete_sub "svs_hs_request"
	cmd_del("hostserv/request");
	cmd_del("hostserv/waiting");
}

sub svs_hs_request {
my ($user, @sargv) = @_;
my $account = $Chakora::DB_account{lc($user}{name};
	if (!defined($sargv[1])) {
		serv_notice("hostserv", $user, "Not enough paraneters. Syntax: request <vhost>");
		return;
	}
	if (!is_identified($user)) {
		serv_notice("hostserv", $user, "You must be logged in order to use this command.");
		return;
	}
	if ($sargv[1] != *.*) {
		serv_notice("hostserv", $user, "The vHost you entered is not in a vaild format.");
		return;
	}
	if ($sargv[1] == *.com) {
		serv_notice("hostserv", $user, "The vHost you entered will need to verified. Please wait for an Network operator to contact you.");
		$Chakora::DB_hpst{lc($user)}{host} = $sargv;
		svsilog("hostserv", $user, "REQUEST", $sargv[1]);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: REQUEST: $sargv[1]")
		
	}
	if ($sargv[1] == *.net) {
		serv_notice("hostserv", $user, "The vHost you entered will need to verified. Please wait for an Network operator to contact you.");
		$Chakora::DB_hpst{lc($user)}{host} = $sargv;
		svsilog("hostserv", $user, "REQUEST", $sargv[1]);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: REQUEST: $sargv[1]");
		
	}
	if ($sargv[1] == *.org) {
		serv_notice("hostserv", $user, "The vHost you entered will need to verified. Please wait for an Network operator to contact you.");
		$Chakora::DB_hpst{lc($user)}{host} = $sargv;
		svsilog("hostserv", $user, "REQUEST", $sargv[1]);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: REQUEST: $sargv[1]");
		
	}
	if ($sargv[1] == *.co.cc) {
		serv_notice("hostserv", $user, "The vHost you entered will need to verified. Please wait for an Network operator to contact you.");
		$Chakora::DB_hosts
		svsilog("hostserv", $user, "REQUEST", $sargv[1]);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: REQUEST: $sargv[1]");
		
	}
	if ($sargv[1] == *.info) {
		serv_notice("hostserv", $user, "The vHost you entered will need to verified. Please wait for an Network operator to contact you.");
		$Chakora::DB_hpst{lc($user)}{host} = $sargv;
		svsilog("hostserv", $user, "REQUEST", $sargv[1]);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: REQUEST: $sargv[1]");
		
	}
	if ($sargv[1] == *.vhost) {
		serv_notice("hostserv", $user, "The vHost you entered will be looked over by our staff.");
		$Chakora::DB_hpst{lc($user)}{host} = $sargv;
		svsilog("hostserv", $user, "REQUEST", $sargv[1]);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): HostServ: REQUEST: $sargv[1]");
		
	}
	
}
svs_hs_waiting {
my ($user, @sargv) = @_;
	if ()
}