# nickserv/drop by The Chakora Project. Allows users to drop their account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("nickserv/drop", "The Chakora Project", "0.1", \&init_ns_drop, \&void_ns_drop);

sub init_ns_drop {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
	cmd_add("nickserv/drop", "Drops your account from services database.", "DROP will allow you to drop your NickServ nickname/account,\nonce you have deleted your nick/account, it may not be restored.\nThis action is not reversable.\n[T]\nSyntax: DROP [nick] <password>\n", \&svs_ns_drop);
}

sub void_ns_drop {
	delete_sub 'init_ns_drop';
	delete_sub 'svs_ns_drop';
	cmd_del("nickserv/drop");
	delete_sub 'void_ns_drop';
}

sub svs_ns_drop {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {	# User is not logged in.
		if (!defined($sargv[1])) {
			serv_notice("nickserv", $user, "Not enough parameters. Syntax: DROP [nick] <password>");
			return;
		} 
	
		if (!defined($sargv[2])) {
			serv_notice("nickserv", $user, "Not enough parameters. Syntax: DROP [nick] <password>");
			return;		
		}
	
		if (!is_registered(1, $sargv[1])) {
			serv_notice("nickserv", $user, "Nickname \002$sargv[1]\002 is not registered.");
			return;
		}
	
		my $pass = hash($sargv[2]);
		my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
		my $nick = $Chakora::DB_nick{lc($sargv[1])}{nick};
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "DROP:FAIL:BADPASS", $nick);
			svsflog('commands', uidInfo($user, 1).": NickServ: DROP:FAIL:BADPASS: $nick");
			return;
		}
		
		my ($dele);
		svsilog("nickserv", $user, "DROP", $nick);
		svsflog('commands', uidInfo($user, 1).": NickServ: DROP: $nick");
		$dele .= 'delete $Chakora::DB_nick{lc(\''.$nick.'\')}; serv_logout(\''.$user.'\'); event_logout(\''.$user.'\', \''.uidInfo($user, 9).'\'); ';
		my $i = 0;
		foreach my $nkey (keys %Chakora::DB_nick) {
			if (lc($Chakora::DB_nick{$nkey}{account}) eq lc($account) and $nkey ne $nick) {
				$i = 1;
			}
		}
		if ($i == 0) {
			svsilog("nickserv", $user, "DROP:PROCESS", "Automatically dropping account \002$account\002");
			svsflog('commands', uidInfo($user, 1).": NickServ: DROP:PROCESS: Automatically dropping account $account");
			$dele .= 'delete $Chakora::DB_account{lc(\''.$account.'\')}; ';
			foreach my $ukey (keys %Chakora::uid) {
				if (lc($Chakora::uid{$ukey}{'account'}) eq lc($account)) {
					serv_logout($ukey);
				}
			}
			foreach my $ckey (keys %Chakora::DB_chan) {
				if (lc($Chakora::DB_chan{$ckey}{founder}) eq lc($account)) {
					if (!metadata(2, $ckey, 'data:successor')) {
						svsilog("nickserv", $user, "DROP:PROCESS", "Automatically dropping channel \002".$Chakora::DB_chan{$ckey}{name}."\002");
						svsflog('commands', uidInfo($user, 1).": NickServ: DROP:PROCESS: Automatically dropping channel ".$Chakora::DB_chan{$ckey}{name});
						$dele .= 'delete $Chakora::DB_chan{\''.$ckey.'\'}; ';
						foreach my $fkey (keys %Chakora::DB_chanflags) {
							if ($Chakora::DB_chanflags{$fkey}{chan} eq lc($ckey)) {
								$dele .= 'delete $Chakora::DB_chanflags{\''.$fkey.'\'}; '
							}
						}
						if (module_exists("chanserv/main") and metadata(2, $ckey, 'option:guard') and lc($ckey) ne lc(config('log', 'logchan'))) {
							$dele .= 'serv_part(\'chanserv\', \''.$ckey.'\', \'Channel dropped.\');';
						}
					}
					else {
						svsilog("nickserv", $user, "DROP:PROCESS", "Automatically succeeding channel \002".$Chakora::DB_chan{$ckey}{name}."\002 to \002".metadata(2, $ckey, 'data:successor')."\002");
						svsflog('commands', uidInfo($user, 1).": NickServ: DROP:PROCESS: Automatically succeeding channel ".$Chakora::DB_chan{$ckey}{name}." to ".metadata(2, $ckey, 'data:successor'));
						$Chakora::DB_chan{$ckey}{founder} = metadata(2, $ckey, 'data:successor');
						my $flags = '+vVotskiRmF';
						if (defined $Chakora::PROTO_SETTINGS{owner}) {
							$flags .= 'qQ';
						}
						elsif (defined $Chakora::PROTO_SETTINGS{admin}) {
							$flags .= 'aA';
						}
						elsif (defined $Chakora::PROTO_SETTINGS{halfop}) {
							$flags .= 'hH';
						}
						flags($ckey, metadata(2, $ckey, 'data:successor'), $flags);
					}
				}
			}
			foreach my $akey (keys %Chakora::DB_chanflags) {
				if (lc($Chakora::DB_chanflags{$akey}{account}) eq lc($account)) {
					$dele .= 'delete $Chakora::DB_chanflags{\''.$akey.'\'}; ';
				}
			}			
		}
		
		$dele .= '1; ';
		eval($dele) or svsilog("nickserv", $user, "DROP:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." NickServ: DROP:FAIL: ".$@) and serv_notice("nickserv", $user, "An error occurred. No data was deleted. Please report this to an IRCop immediately.") and return;
		serv_notice("nickserv", $user, "You have successfully dropped the nickname \002$nick\002.");
		if ($i == 0) {
			serv_notice("nickserv", $user, "You have successfully dropped the account \002$account\002.");
		}
	} else {	# User is logged in.
		if (!defined($sargv[1])) {
			serv_notice("nickserv", $user, "Not enough parameters. Syntax: DROP <password>");
			return;
		} 
		my $pass = hash($sargv[2]);
		my $account = $Chakora::DB_nick{uidInfo($user, 1)}{account};
		my $nick = $Chakora::DB_nick{uidInfo($user, 1)}{account};
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "DROP:FAIL:BADPASS", $nick);
			svsflog('commands', uidInfo($user, 1).": NickServ: DROP:FAIL:BADPASS: $nick");
			return;
		}
				
		my ($dele);
		svsilog("nickserv", $user, "DROP", $nick);
		svsflog('commands', uidInfo($user, 1).": NickServ: DROP: $nick");
		$dele .= 'delete $Chakora::DB_nick{lc(\''.$nick.'\')}; serv_logout(\''.$user.'\'); event_logout(\''.$user.'\', \''.uidInfo($user, 9).'\'); ';
		my $i = 0;
		foreach my $nkey (keys %Chakora::DB_nick) {
			if (lc($Chakora::DB_nick{$nkey}{account}) eq lc($account) and $nkey ne $nick) {
				$i = 1;
			}
		}
		if ($i == 0) {
			svsilog("nickserv", $user, "DROP:PROCESS", "Automatically dropping account \002$account\002");
			svsflog('commands', uidInfo($user, 1).": NickServ: DROP:PROCESS: Automatically dropping account $account");
			$dele .= 'delete $Chakora::DB_account{lc(\''.$account.'\')}; ';
			foreach my $ukey (keys %Chakora::uid) {
				if (lc($Chakora::uid{$ukey}{'account'}) eq lc($account)) {
					serv_logout($ukey);
				}
			}
			foreach my $ckey (keys %Chakora::DB_chan) {
				if (lc($Chakora::DB_chan{$ckey}{founder}) eq lc($account)) {
					if (!metadata(2, $ckey, 'data:successor')) {
						svsilog("nickserv", $user, "DROP:PROCESS", "Automatically dropping channel \002".$Chakora::DB_chan{$ckey}{name}."\002");
						svsflog('commands', uidInfo($user, 1).": NickServ: DROP:PROCESS: Automatically dropping channel ".$Chakora::DB_chan{$ckey}{name});
						$dele .= 'delete $Chakora::DB_chan{\''.$ckey.'\'}; ';
						foreach my $fkey (keys %Chakora::DB_chanflags) {
							if ($Chakora::DB_chanflags{$fkey}{chan} eq $ckey) {
								$dele .= 'delete $Chakora::DB_chanflags{\''.$fkey.'\'}; '
							}
						}
						foreach my $dkey (keys %Chakora::DB_chandata) {
							if ($Chakora::DB_chandata{$dkey}{chan} eq $ckey) {
								$dele .= 'delete $Chakora::DB_chandata{\''.$dkey.'\'}; ';
							}
						}
						if (module_exists("chanserv/main") and metadata(2, $ckey, 'option:guard') and lc($ckey) ne lc(config('log', 'logchan'))) {
							$dele .= 'serv_part(\'chanserv\', \''.$ckey.'\', \'Channel dropped.\'); ';
						}
					}
					else {
						svsilog("nickserv", $user, "DROP:PROCESS", "Automatically succeeding channel \002".$Chakora::DB_chan{$ckey}{name}."\002 to \002".metadata(2, $ckey, 'data:successor')."\002");
						svsflog('commands', uidInfo($user, 1).": NickServ: DROP:PROCESS: Automatically succeeding channel ".$Chakora::DB_chan{$ckey}{name}." to ".metadata(2, $ckey, 'data:successor'));
						$Chakora::DB_chan{$ckey}{founder} = metadata(2, $ckey, 'data:successor');
						my $flags = '+voOtskiRmAF';
						if (defined $Chakora::PROTO_SETTINGS{owner}) {
							$flags .= 'q';
						}
						elsif (defined $Chakora::PROTO_SETTINGS{admin}) {
							$flags .= 'a';
						}
						elsif (defined $Chakora::PROTO_SETTINGS{halfop}) {
							$flags .= 'h';
						}
						$dele .= 'my ($i);
								foreach my $sfkey (keys %Chakora::DB_chanflags) {
									if ($Chakora::DB_chanflags{$sfkey}{chan} eq \''.$ckey.'\' and lc($Chakora::DB_chanflags{$sfkey}{account}) eq lc(\''.metadata(2, $ckey, 'data:successor').'\'))
									{
										$Chakora::DB_chanflags{$sfkey}{flags} = \''.$flags.'\';
										$i = 1;
									}
								}
								if (!$i) {
									$Chakora::DBCFLAST += 1;
									$Chakora::DB_chanflags{$Chakora::DBCFLAST}{chan}    = \''.$ckey.'\';
									$Chakora::DB_chanflags{$Chakora::DBCFLAST}{account} = \''.metadata(2, $ckey, 'data:successor').'\';
									$Chakora::DB_chanflags{$Chakora::DBCFLAST}{flags}   = \''.$flags.'\';
								}';
						if (module_exists("chanserv/main")) {
							foreach my $sukey (keys %Chakora::uid) {
								if (lc($Chakora::uid{$sukey}{'account'}) eq lc(metadata(2, $ckey, 'data:successor'))) {
									apply_status($sukey, $ckey);
									serv_notice("chanserv", $sukey, "You are now the founder of channel \002".$Chakora::DB_chan{$ckey}{name}."\002.");
								}
							}
						}
						metadata_del(2, $ckey, 'data:successor');
					}
				}
			}
			foreach my $akey (keys %Chakora::DB_chanflags) {
				if (lc($Chakora::DB_chanflags{$akey}{account}) eq lc($account)) {
					$dele .= 'delete $Chakora::DB_chanflags{\''.$akey.'\'}; ';
				}
			}			
		}
		
		$dele .= '1; ';
		eval($dele) or svsilog("nickserv", $user, "DROP:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." NickServ: DROP:FAIL: ".$@) and serv_notice("nickserv", $user, "An error occurred. No data was deleted. Please report this to an IRCop immediately.") and return;
		serv_notice("nickserv", $user, "You have successfully dropped the nickname \002$nick\002.");
		if ($i == 0) {
			serv_notice("nickserv", $user, "You have successfully dropped the account \002$account\002.");
		}
	}
}
