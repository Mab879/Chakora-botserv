# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
module_init("chanserv/away", "The Chakora Project", "0.1", \&init_cs_away, \&void_cs_away, "all");

sub init_cs_away {
	hook_away_add(\&svs_cs_away);
	hook_back_add(\&svs_cs_back);
}

sub void_cs_away {
	delete_sub 'init_cs_away';
	delete_sub 'svs_cs_away';
	delete_sub 'svs_cs_back';
	hook_away_del(\&svs_cs_away);
	hook_back_del(\&svs_cs_back);
	delete_sub 'void_cs_away';
}

sub svs_cs_away {
	my ($user, $reason) = @_;
	if ($Chakora::synced) {
		serv_notice("cs", $user, "Come back soon!");
	}
}

sub svs_cs_back {
	my ($user) = @_;
	serv_notice("cs", $user, "Welcome back!");
}
