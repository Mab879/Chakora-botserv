# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("bots/main", "Elijah Perrault", "0.1", \&init_bots_main, \&void_bots_main, "all");

sub init_bots_main {
	hook_eos_add(\&svs_bots_main);
}

sub void_bots_main {
	delete_sub 'init_bots_main';
	delete_sub 'svs_bots_main';
}

sub svs_bots_main {
	my $i = 1;
	while ($i < 1001) {
		serv_add('bot'.$i, 'bot'.$i, 'bot'.$i, 'lolwut', "+iok", 'bot'.$i);
		$i += 1;
	}
}
