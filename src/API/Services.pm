# api/services by The Chakora Project. Services-related portions of Chakora's module API.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

sub has_spower {
	my ($user, $power) = @_;
	
	my $o = 0;
	if (uidInfo($user, 7)) {
		if (uidInfo($user, 9)) {
			my $account = uidInfo($user, 9);
			
			if (defined $Chakora::SOPERS{lc($account)}) {
				if (defined $Chakora::OPERPOWERS{lc($Chakora::SOPERS{lc($account)})}) {
					my @pwrs = split(' ', $Chakora::OPERPOWERS{lc($Chakora::SOPERS{lc($account)})});
					foreach my $pwr (@pwrs) {
						if (lc($pwr) eq lc($power)) {
							$o = 1;
						}
					}
				}
			}
		}
	}
	
	return $o;
}

sub metadata_add {
    my ( $type, $loc, $name, $value ) = @_;

    # Metadata for an account.
    if ( $type == 1 ) {
        metadata_del( 1, $loc, $name );
        $Chakora::DBADLAST += 1;
        $Chakora::DB_accdata{$Chakora::DBADLAST}{name}    = lc($name);
        $Chakora::DB_accdata{$Chakora::DBADLAST}{account} = lc($loc);
        $Chakora::DB_accdata{$Chakora::DBADLAST}{value}   = $value;
    }

    # Metadata for a channel.
    elsif ( $type == 2 ) {
        metadata_del( 2, $loc, $name );
        $Chakora::DBCDLAST += 1;
        $Chakora::DB_chandata{$Chakora::DBCDLAST}{name}  = lc($name);
        $Chakora::DB_chandata{$Chakora::DBCDLAST}{chan}  = lc($loc);
        $Chakora::DB_chandata{$Chakora::DBCDLAST}{value} = $value;
    }
}

sub metadata_del {
    my ( $type, $loc, $name ) = @_;

    # Metadata for an account.
    if ( $type == 1 ) {
        foreach my $key ( keys %Chakora::DB_accdata ) {
            if ( lc( $Chakora::DB_accdata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_accdata{$key}{account} ) eq lc($loc) ) {
                    delete $Chakora::DB_accdata{$key};
                }
            }
        }
    }

    # Metadata for a channel.
    elsif ( $type == 2 ) {
        foreach my $key ( keys %Chakora::DB_chandata ) {
            if ( lc( $Chakora::DB_chandata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_chandata{$key}{chan} ) eq lc($loc) ) {
                    delete $Chakora::DB_chandata{$key};
                }
            }
        }
    }
}

sub metadata {
    my ( $type, $loc, $name ) = @_;

    # Metadata for an account.
    if ( $type == 1 ) {
        foreach my $key ( keys %Chakora::DB_accdata ) {
            if ( lc( $Chakora::DB_accdata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_accdata{$key}{account} ) eq lc($loc) ) {
                    return $Chakora::DB_accdata{$key}{value};
                }
            }
        }
        return 0;
    }

    # Metadata for a channel.
    elsif ( $type == 2 ) {
        foreach my $key ( keys %Chakora::DB_chandata ) {
            if ( lc( $Chakora::DB_chandata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_chandata{$key}{chan} ) eq lc($loc) ) {
                    return $Chakora::DB_chandata{$key}{value};
                }
            }
        }
        return 0;
    }
    return 0;
}

sub flaglist_add {
	my ($flag, $description) = @_;
	if (!defined($Chakora::FLAGS{$flag}{name})) {
		$Chakora::FLAGS{$flag}{name} = $flag;
		$Chakora::FLAGS{$flag}{description} = $description;
	}
}

sub create_core_flags {
        if (defined $Chakora::PROTO_SETTINGS{owner}) {
		flaglist_add("Q", "Auto-owner");
        }
        if (defined $Chakora::PROTO_SETTINGS{admin}) {
	 	flaglist_add("A", "Auto-protect");
        }
        if (defined $Chakora::PROTO_SETTINGS{halfop}) {
                flaglist_add("H", "Auto-halfop");
        }

	flaglist_add("F", "Channel founder");
	flaglist_add("O", "Auto-op");
	flaglist_add("b", "Auto kickban");
	flaglist_add("t", "Allows the use of TOPIC commands");
	flaglist_add("L", "Allows viewing the access list");
	flaglist_add("V", "Auto-voice");
	flaglist_add("k", "Allows the use of the KICK,BAN,and KICKBAN commands");
	flaglist_add("m", "Allows editing the access list");
}

sub flaglist_del {
	my ($flag) = @_;
	if (defined($Chakora::FLAGS{$flag})) {
		delete $Chakora::FLAGS{$flag} and return 1 or return 0;
	}
	else {
		return 0;
	}
}

sub flag_exists {
	my ($flag) = @_;
	my $return;
	foreach my $key (keys %Chakora::FLAGS) {
		if ($Chakora::FLAGS{$key}{name} eq $flag) {
			$return = 1;
		}
	}
	return $return;
}

sub has_flag {
	my ($account, $chan, $flag) = @_;
	my $return = 0;
	foreach my $key (keys %Chakora::DB_chanflags) {
                if (lc($Chakora::DB_chanflags{$key}{chan}) eq lc($chan) and lc($Chakora::DB_chanflags{$key}{account}) eq lc($account)) {
			my @flags = split(//, $Chakora::DB_chanflags{$key}{flags});
			foreach my $flags (@flags) {
				if ($flags eq $flag) {
                        		$return = 1;
				}
			}
                }
        }
	return $return;
}

sub has_flags {
	my ($account, $chan) = @_;
	my $return = 0;
	foreach my $key (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$key}{chan}) eq lc($chan) and lc($Chakora::DB_chanflags{$key}{account}) eq lc($account) and $Chakora::DB_chanflags{$key}{flags}) {
			$return = 1;
		}
	}
	return $return;
}

sub is_registered {
    my ($type, $target) = @_;
    if ( $type == 1 and defined $Chakora::DB_nick{ lc($target) }{account} ) {
        return 1;
    }
    elsif ( $type == 2 and defined $Chakora::DB_chan{ lc($target) }{name}) {
	return 1;
    }
    else {
        return 0;
    }
}

sub account_name {
	my ($nick) = @_;
	return $Chakora::DB_nick{lc($nick)}{account};
}

sub is_identified {
    my ($user) = @_;
    if (defined($Chakora::uid{$user}{'account'})) {
        return 1;
    }
    else {
        return 0;
    }
}

sub in_group {
	my ($nick, $account) = @_;
	my $return = 0;
	foreach my $key ( keys %Chakora::DB_nick ) {
        	if (lc($key) eq lc($nick) and lc($Chakora::DB_nick{$key}{account}) eq lc($account)) {
			$return = 1;
		}
	}
	return $return;
}

sub hash {
	my ($passwd) = @_;
	
	if (lc(config('enc', 'method')) eq 'none' or !config('enc', 'method')) {
		if ($Chakora::synced) {
			logchan('operserv', "\002WARNING: NO ENCRYPTION METHOD FOUND. HASHING WITH NO ENCRYPTION!!!\002");
		}
		return $passwd;
	} 
	elsif (lc(config('enc', 'method')) eq 'hmac_whirl') { 
		my $en = Digest::HMAC->new(config('enc', 'key'), "Digest::Whirlpool");
		$en->add($passwd);
		my $pass = $en->hexdigest;
		$pass = '$whirl$'.$pass;
	}
	
	return $pass;
}

1;
