# memoserv/main by The Chakora Project. Creates the MemoServ service.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("memoserv/main", "The Chakora Project", "0.1", \&init_ms_main, \&void_ms_main, "all");

sub init_ms_main {
	create_cmdtree("memoserv");
	if (!$Chakora::synced) { hook_pds_add(\&svs_ms_main); }
	else { svs_ms_main(); }
}

sub void_ms_main {
	delete_sub 'init_ms_main';
	delete_sub 'svs_ms_main';
	hook_pds_del(\&svs_ms_main);
	serv_del('MemoServ');
	delete_cmdtree("memoserv");
	delete_sub 'void_ms_main';
}

sub svs_ms_main {
	if (!config('memoserv', 'nick')) {
		svsflog('modules', 'Unable to create MemoServ. memoserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002MemoServ\002: Unable to create MemoServ. memoserv:nick is not defined in the config!"); }
		module_void("memoserv/main");
	} elsif (!config('memoserv', 'user')) {
		svsflog('modules', 'Unable to create MemoServ. memoserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002MemoServ\002: Unable to create MemoServ. memoserv:user is not defined in the config!"); }
		module_void("memoserv/main");
	} elsif (!config('memoserv', 'host')) {
		svsflog('modules', 'Unable to create MemoServ. memoserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002MemoServ\002: Unable to create MemoServ. memoserv:host is not defined in the config!"); }
		module_void("memoserv/main");
	} elsif (!config('memoserv', 'real')) {
		svsflog('modules', 'Unable to create MemoServ. memoserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002MemoServ\002: Unable to create MemoServ. memoserv:real is not defined in the config!"); }
		module_void("memoserv/main");
	} else {
		my $modes = '+io';
		if (lc(config('server', 'ircd')) eq 'inspircd12') {
			if ($Chakora::PROTO_SETTINGS{god}) {
				$modes .= 'k';
			}
		} elsif (lc(config('server', 'ircd')) eq 'charybdis') {
			$modes .= 'S';
		} else {
			svsflog('modules', 'Unable to create MemoServ. Unsupported protocol!');
			if ($Chakora::synced) { logchan('operserv', "\002MemoServ\002: Unable to create MemoServ. Unsupported protocol!"); }
			module_void("memoserv/main");
		}
		serv_add('memoserv', config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), $modes, config('memoserv', 'real'));
	}
}
