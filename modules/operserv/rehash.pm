# operserv/rehash by The Chakora Project. Adds REHASH to OperServ, which reloads the configuration file and modifies settings in the runtime to match the updated config.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/rehash", "The Chakora Project", "0.1", \&init_os_rehash, \&void_os_rehash, "all");

sub init_os_rehash {
	cmd_add("operserv/rehash", "Reloads the configuration file.", "REHASH will open all the configuration files, read them,\noverwrite current settings in memory with the new ones\nand modify the runtime to operate with the new settings.\n[T]\nSyntax: REHASH", \&svs_os_rehash);
}

sub void_os_rehash {
	delete_sub 'init_os_rehash';
	delete_sub 'svs_os_rehash';
	cmd_del("operserv/rehash");
	delete_sub 'void_os_rehash';
}

sub svs_os_rehash {
	my ($user, @sargv) = @_;

	if (!uidInfo($user, 9)) {
		serv_notice("operserv", $user, "You must be logged in to perform this operation.");
		return;
	}
	if (!has_spower($user, 'operserv:rehash')) {
		serv_notice("operserv", $user, "Permission denied.");
		return;
	}
	
	our (%OPERPOWERS, %SOPERS) = @_;
our ($ssopower);
if (-e "$ROOT_SRC/../etc/soper.conf") {
	open FILE, "<$ROOT_SRC/../etc/soper.conf" or error("Unable to open soper.conf: $!");
	my @saa = <FILE>;
	close FILE;
	
	foreach my $sab (@saa) {
		unless (substr($sab, 0, 1) eq '#') {
			my @sac = split(';', $sab);
			foreach my $sad (@sac) {
				my @sae = split(' ', $sad);
				
				if (defined $sae[0]) {
					if ($sae[0] eq 'BOF') {
						if (defined $ssopower) {
							error("chakora", "soper.conf: BOF/$sae[1] conflicts with BOF/$ssopower: Received another BOF before an EOF. Aborting.");
						}
						if (!defined $sae[1]) {
							error("chakora", "soper.conf: Empty BOF received. Aborting.");
						}
						$ssopower = $sae[1];
					}
					elsif ($sae[0] eq 'EOF') {
						if (!defined $ssopower) {
							error("chakora", "soper.conf: Received EOF but no BOF was sent first. Aborting.");
						}
						undef $ssopower;
					}
					elsif ($sae[0] eq 'INCLUDE') {
						if (!defined $ssopower) {
							print "[OPERPOWERS] Received INCLUDE but no BOF was sent first. Ignoring.\n";
						}
						elsif (!defined $sae[1]) {
							print "[OPERPOWERS] Received empty INCLUDE. Ignoring.\n";
						}
						elsif (!defined $OPERPOWERS{$sae[1]}) {
							print "[OPERPOWERS] INCLUDE tried to include the '$sae[1]' powerset, but it doesn't exist! Ignoring.\n";
						}
						else {
							$OPERPOWERS{$ssopower} .= " ".$OPERPOWERS{$sae[1]};
						}
					}
					elsif ($sae[0] eq 'SOPER') {
						if (!defined $sae[1] or !defined $sae[2]) {
							print "[OPERPOWERS] Received SOPER with missing arguments. Ignoring.\n";
						}
						else {
							$SOPERS{lc($sae[1])} = lc($sae[2]);
						}
					}
					else {
						if (defined $ssopower) {
							$OPERPOWERS{$ssopower} .= " ".$sae[0];
						}
						else {
							print "[OPERPOWERS] Power $sae[0] received outside of power set, ignoring.\n";
						}
					}
				}
			}
		}
	}
}
undef $ssopower;
}

1;
