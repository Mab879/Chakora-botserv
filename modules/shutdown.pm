# /  __ \ |         | |                  
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#    	    operserv/shutdown
#
# Adds SHUTDOWN command to services.
use strict;
use warnings;

cmd_add("operserv/shutdown", "The Chakora Project", "1.0", "Shuts down services.", "", \&svs_os_shutdown, "all");

sub svs_os_shutdown {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	serv_notice("os", substr($rex[0], 1), "LOLWUT"); 
}
1;
