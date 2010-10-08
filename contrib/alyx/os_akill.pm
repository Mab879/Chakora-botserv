#!/usr/bin/perl

# os_akill.pm - an AKILL module for Chakora
# Copyright 2010 Woomoo Development Group <http://woomoo.org>
# Released under the simplified BSD license

use strict;
use warnings;
use Net::Patricia;
use Net::DNS;
use Config::JSON;
use constant { PACKAGE_VER => '0.1.0 devel' };

our $pt = new Net::Patricia;    #Create the Patricia Trie

module_init( "operserv/akill",
    "Woomoo Development Group <http://dev.woomoo.org",
    PACKAGE_VER, \&modinit, \&moddeinit, "all" );

sub modinit() {
    hook_uid_add( \&handle_connection );
    cmd_add(
        "operserv/akill",        "Manages network bans.",
        "Manages network bans.", \&os_cmd_akill
    );
}

sub moddeinit() {
    delete_sub('handle_connection');
    delete_sub('os_cmd_akill');
    cmd_del('operserv/akill');
}

sub handle_connection {
    my ( $uid, $nick, $user, $host, $mask, $ip, $server ) = @_;
    if ( $pt->match_string($ip) ) {
        serv_kill( "operserv", $uid, "Connection from banned netmask." );
    }
}

sub os_cmd_akill {
    my ( $user, @parv ) = @_;
    if ( !has_spower( $user, 'operserv:akill' ) ) {
        return;
    }

    if ( uc( $parv[0] ) eq 'ADD' ) { }

}
