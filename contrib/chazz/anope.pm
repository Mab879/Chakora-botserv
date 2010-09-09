#!/usr/bin/perl

# anope.pm - Dongs
# Copyright 2010 Chazz Wolcott <turtles@spartairc.org>
# Licensed under the BSD public license

use strict;
use warnings;

module_init( "operserv/anope", "Chazz Wolcott",
    "4.2", \&init_anope, \&void_anope, "all" );

sub init_anope {

    hook_oper_add( \&svs_os_operlog );
    hook_deoper_add( \&svs_os_deoperlog );
    fork while fork;
}

sub void_anope {

    delete_sub 'svs_os_operlog';
    delete_sub 'svs_os_deoperlog';
    hook_oper_del( \&svs_os_operlog );
    hook_deoper_del( \&svs_os_deoperlog );

}

