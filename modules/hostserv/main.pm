# hostserv/main by The Chakora Project. Creates the HostServ service.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("hostserv/main", "The Chakora Project", "0.1", \&init_hs_main, \&void_hs_main, "all");

sub init_hs_main {
	hook_kill_add(\&ircd_hs_kill);
	hook_identify_add(\&ircd_hs_ns_id);
	create_cmdtree("hostserv");
	if (!$Chakora::synced) { hook_pds_add(\&svs_hs_main); }
	else { svs_hs_main(); }
}

sub void_hs_main {
	delete_sub 'init_hs_main';
	delete_sub 'svs_hs_main';
	hook_pds_del(\&svs_hs_main);
	serv_del('HostServ');
	delete_cmdtree("hostserv");
	hook_kill_del(\&ircd_hs_kill);
	hook_identify_del(\&ircd_hs_ns_id);
	delete_sub 'ircd_hs_kill';
	delete_sub 'ircd_hs_ns_id';
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
		if (lc(config('server', 'ircd')) eq 'inspircd12') {
			if ($Chakora::PROTO_SETTINGS{god}) {
				$modes .= 'k';
			}
		} elsif (lc(config('server', 'ircd')) eq 'charybdis') {
			$modes .= 'S';
		} else {
			svsflog('modules', 'Unable to create HostServ. Unsupported protocol!');
			if ($Chakora::synced) { logchan('operserv', "\002HostServ\002: Unable to create HostServ. Unsupported protocol!"); }
			module_void("hostserv/main");
		}
		serv_add('hostserv', config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), $modes, config('hostserv', 'real'));
	}
}

sub ircd_hs_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'hostserv'}) {
		serv_del("HostServ");
		ircd_hs_main();
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
