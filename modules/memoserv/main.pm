# memoserv/main by The Chakora Project. Creates the MemoServ service for sending and receiving memos.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("memoserv/main", "The Chakora Project", "0.1", \&init_ms_main, \&void_ms_main);

sub init_ms_main {
	hook_kill_add(\&ircd_ms_kill);
	hook_kick_add(\&ircd_ms_kick);
	create_cmdtree("memoserv");
	if (!$Chakora::synced) { hook_pds_add(\&svs_ms_main); }
	else { svs_ms_main(); return 1; }
}

sub void_ms_main {
	delete_sub 'memo_send';
	delete_sub 'memo_del';
	delete_sub 'init_ms_main';
	delete_sub 'svs_ms_main';
	hook_pds_del(\&svs_ms_main);
	hook_kill_del(\&ircd_ms_kill);
	hook_kick_del(\&ircd_ms_kick);
	serv_del('MemoServ');
	delete_cmdtree("memoserv");
	delete_sub 'ircd_ms_kill';
	delete_sub 'ircd_ms_kick';
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
                if (defined $Chakora::PROTO_SETTINGS{deaf} and !config('services', 'use_fantasy')) { $modes .= $Chakora::PROTO_SETTINGS{deaf}; }
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add('memoserv', config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), $modes, config('memoserv', 'real'));
	}
}

sub ircd_ms_kill {
	my ($user, $target, undef) = @_;
	
	if ($target eq svsUID("memoserv")) {
		serv_del("MemoServ");
		ircd_ms_main();
	}
}

sub ircd_ms_kick {
        my ($user, $chan, $target, undef) = @_;

        if ($target eq svsUID("memoserv")) {
                serv_join("memoserv", $chan);
                serv_kick("memoserv", $chan, $user, "Please do not kick services.");
        }
}

sub memo_send {
	my ($from, $to, $body) = @_;
	$to = lc($to);
	
	$Chakora::DBMMLAST += 1;
	$Chakora::DB_memo{$Chakora::DBMMLAST}{to}   = $to;
	$Chakora::DB_memo{$Chakora::DBMMLAST}{from} = $from;
	$Chakora::DB_memo{$Chakora::DBMMLAST}{time} = time();
	$Chakora::DB_memo{$Chakora::DBMMLAST}{new}  = 1;
	$Chakora::DB_memo{$Chakora::DBMMLAST}{body} = $body;
}

sub memo_del {
	my ($account, $memo) = @_;
	
	my (%memos);
	my $i = 0;
	foreach my $key (keys %Chakora::DB_memo) {
		if ($Chakora::DB_memo{$key}{to} eq lc($account)) {
			$i += 1;
			$memos{$i} = $Chakora::DB_memo{$key}{body};
		}
	}
	
	foreach my $key (keys %memos) {
		if ($key eq $memo) {
			return $memos{$key};
		}
	}
	return "FAIL_NOEXIST";
}
