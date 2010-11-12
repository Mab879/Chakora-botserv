# hostserv/main by The Chakora Project. Creates the HostServ service.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("hostserv/main", "The Chakora Project", "0.1", \&init_hs_main, \&void_hs_main);

sub init_hs_main {
	hook_kill_add(\&ircd_hs_kill);
        hook_kick_add(\&ircd_hs_kick);
	hook_identify_add(\&ircd_hs_ns_id);
	create_cmdtree("hostserv");
	if (!$Chakora::synced) { hook_pds_add(\&svs_hs_main); }
	else { svs_hs_main(); return 1; }
}

sub void_hs_main {
	delete_sub 'init_hs_main';
	delete_sub 'svs_hs_main';
	hook_pds_del(\&svs_hs_main);
	serv_del('HostServ');
	delete_cmdtree("hostserv");
	hook_kill_del(\&ircd_hs_kill);
        hook_kick_add(\&ircd_hs_kick);
	hook_identify_del(\&ircd_hs_ns_id);
	delete_sub 'ircd_hs_kill';
	delete_sub 'ircd_hs_ns_id';
	delete_sub 'ircd_hs_kick';
	delete_sub 'void_hs_main';
}

sub svs_hs_main {
	if (!config('hostserv', 'nick')) {
		svsflog('modules', 'Unable to create HostServ. hostserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002HostServ\002: Unable to create HostServ. hostserv:nick is not defined in the config!"); }
		module_void("hostserv/main");
	} elsif (!config('hostserv', 'user')) {
		svsflog('modules', 'Unable to create HostServ. hostserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002HostServ\002: Unable to create HostServ. hostserv:user is not defined in the config!"); }
		module_void("hostserv/main");
	} elsif (!config('hostserv', 'host')) {
		svsflog('modules', 'Unable to create HostServ. hostserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002HostServ\002: Unable to create HostServ. hostserv:host is not defined in the config!"); }
		module_void("hostserv/main");
	} elsif (!config('hostserv', 'real')) {
		svsflog('modules', 'Unable to create HostServ. hostserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002HostServ\002: Unable to create HostServ. hostserv:real is not defined in the config!"); }
		module_void("hostserv/main");
	} else {
		my $modes = '+io';
                if (defined $Chakora::PROTO_SETTINGS{deaf} and !config('services', 'use_fantasy')) { $modes .= $Chakora::PROTO_SETTINGS{deaf}; }
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add('hostserv', config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), $modes, config('hostserv', 'real'));
	}
}

sub ircd_hs_kill {
	my ($user, $target, undef) = @_;
	
	if ($target eq svsUID("hostserv")) {
		serv_del("HostServ");
		ircd_hs_main();
	}
}

sub ircd_hs_kick {
        my ($user, $chan, $target, undef) = @_;

        if ($target eq svsUID("hostserv")) {
                serv_join("hostserv", $chan);
                serv_kick("hostserv", $chan, $user, "Please do not kick services.");
        }
}

sub ircd_hs_ns_id {
	my ($user, $account) = @_;
	
	unless (!metadata(1, $account, 'data:vhost')) {
		if (lc(config('server', 'ircd')) eq 'inspircd12') {
			if ($Chakora::PROTO_SETTINGS{modules} =~ m/m_chghost.so/i) {
				serv_chghost($user, metadata(1, $account, 'data:vhost'));
			}
			else {
				logchan('hostserv', "\002WARNING\002: m_chghost.so is not loaded! Unable to set vHost.");
			}
		}
		else {
			serv_chghost($user, metadata(1, $account, 'data:vhost'));
		}
	}
}
