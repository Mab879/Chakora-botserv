# chanserv/xop by The Chakora Project. Adds XOP support to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/xop", "The Chakora Project", "0.1", \&init_cs_xop, \&void_cs_xop);

sub init_cs_xop {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/vop", "Adds a user to the VOP list", "VOP gives a user predefined flags based on the networks configuration.\n[T]Syntax: VOP <channel> <add/del/list> [nick]", \&svs_cs_vop);
        cmd_add("chanserv/aop", "Adds a user to the AOP list", "AOP gives a user predefined flags based on the networks configuration.\n[T]Syntax: AOP <channel> <add/del/list> [nick]", \&svs_cs_aop);
	fantasy("vop", 0);
	fantasy("aop", 0);
	# Add cmds based on prefixes available: qop, sop, hop
	# Add fantasy for them too
}

sub void_cs_xop {
	delete_sub 'init_cs_xop';
	cmd_del("chanserv/vop");
	cmd_del("chanserv/aop");
	delete_sub 'svs_cs_vop';
	delete_sub 'svs_cs_aop';
	# Delete commands and subs based on prefixes
	delete_sub 'void_cs_xop';
}

sub svs_cs_vop {
	my ($user, @sargv) = @_;

}

sub svs_cs_aop {
        my ($user, @sargv) = @_;
	if (has_flag($user, $sargv[0], "+F")) {
		serv_notice('chanserv', $user, "Adding $sargv[2] to the AOP list for $sargv[0]");
		flags($sargv[2], $chan, config('xop', 'aop');
		apply_status($sargv[2], $sargv[0]);
	} else {
		serv_notice('chanserv', $user, "Only channel founders can add people to the AOP list");
	}
}

