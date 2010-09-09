#!/usr/bin/perl

# os_soper.pm - SOPER information for Chakora
# Copyright 2010 Chazz Wolcott <turtles@spartairc.org>
# Licensed under the BSD public license

use strict;
use warnings;

module_init( "operserv/soper", "Chazz Wolcott",
    "4.2", \&init_os_soper, \&void_os_soper, "all" );

# Set this to 0 and verify it has a block in the config to make userlog use its own service
my $service = "operserv";

sub init_os_userlog {

    hook_oper_add( \&svs_os_operlog );
    hook_deoper_add( \&svs_os_deoperlog );
}

sub void_os_userlog {

    delete_sub 'svs_os_operlog';
    delete_sub 'svs_os_deoperlog';
    hook_oper_del( \&svs_os_operlog );
    hook_deoper_del( \&svs_os_deoperlog );

}

sub svs_os_operlog {
    my ($user) = @_;
    if ($Chakora::synced) {
        send_global("IRCOP FLAG TURN ON");
        send_global("$user IZ OPAR'D");
    }
}

sub svs_os_deoperlog {
    my ($user) = @_;
    if ($Chakora::synced) {
        send_global("IRCOP FLAG TURN OFF");
        send_global("$user IZ DEOPAR'D");
    }
}
