# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#    Operserv Version Module
#          Modules::operserv::version
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/version", "The Chakora Project", "0.1", \&init_os_version, "all");

sub init_os_version {
	cmd_add("operserv/version", "Version", "Display\nservices\nversion", \&svs_os_version);
}

sub svs_os_version {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	serv_notice("os", $user, $Chakora::SERVICES_VERSION." - Developed by starcoder, MattB, chazz, cooper, and Freelancer");
}

1;
