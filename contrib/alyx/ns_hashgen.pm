#!/usr/bin/env perl

# ns_hashgen.pm - Generates a hash in the specified format.
# Copyright (c) 2010 Alexandria Marie Wolcott <alyx@woomoo.org>
# Licensed under the WTFPL, see http://issm.tk/?a=t4n3A2f4 for more information
use strict;
use warnings;
use Hashlib;

module_init('nickserv/hashgen', 'Alexandria Marie Wolcott <alyx@woomoo.org>', '0.1', \&init_ns_hashgen, \&void_ns_hashgen);

sub init_ns_hashgen {
    if (!module_exists("nickserv/main")) {
        module_load("nickserv/main");
    }
    cmd_add("nickserv/hashgen", "Generates a hash", "HASHGEN generates a hash in either the currently used format", \&svs_ns_hashgen);
}

sub void_ns_hashgen {
    delete_sub 'init_ns_hashgen';
    delete_sub 'svs_ns_hashgen';
    cmd_del("nickserv/hashgen");
    delete_sub 'void_ns_hashgen';
}

sub svs_ns_hashgen {
    my ($user, @parv) = @_;
        svsflog('commands', uidInfo($user, 1).': NickServ: HASHGEN');
        my $out = hash($parv[0];
        serv_notice("nickserv", $user, "Generated hash: $out");
        svsilog("nickserv", $user, "HASHGEN", "");
    }
}
