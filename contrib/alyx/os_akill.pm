#!/usr/bin/perl

# os_akill.pm - an AKILL module for Chakora
# Copyright 2010 Alyx Rothschild and Woomoo Development Group <alyx@woomoo.org>
# Released under the simplified BSD license

use strict;
use warnings;
use Net::Patricia;
use Net::DNS;
use Config::JSON;
use constant { PACKAGE_VER => '0.1.0 devel' };

our $pt = new Net::Patricia; #Create the Patricia Trie

module_init( "operserv/akill",
    "Woomoo Development Group <http://dev.woomoo.org",
    PACKAGE_VER, \&modinit, \&moddeinit, "all" );

sub modinit() {
	hook_uid_add(\&handle_connection);
	cmd_add("operserv/akill", "Manages network bans.", "Manages network bans.", \&os_cmd_akill);
}

sub handle_connection
{
}

sub os_cmd_akill
{
}

