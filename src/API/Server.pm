# api/server by The Chakora Project. Server-related functions of Chakora's module API.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

sub parse_mode {
    my ( $modes, $key, $mode ) = @_;
    if ( $key eq '+' ) {
        my @kmodes = split( '\+', $modes );
        my (@mmodes);
        foreach my $lmodes (@kmodes) {
            my @nmodes = split( '-', $lmodes );
            if ( defined $nmodes[0] ) {
                push( @mmodes, $nmodes[0] );
            }
            else {
                push( @mmodes, $lmodes );
            }
        }
        my $ei = 0;
        foreach my $omodes (@mmodes) {
            if ( $omodes =~ m/($mode)/ ) {
                $ei = 1;
            }
        }
        return $ei;
    }
    elsif ( $key eq '-' ) {
        my @kmodes = split( '-', $modes );
        my (@mmodes);
        foreach my $lmodes (@kmodes) {
            my @nmodes = split( '\+', $lmodes );
            if ( defined $nmodes[0] ) {
                push( @mmodes, $nmodes[0] );
            }
            else {
                push( @mmodes, $lmodes );
            }
        }
        my $ei = 0;
        foreach my $omodes (@mmodes) {
            if ( $omodes =~ m/($mode)/ ) {
                $ei = 1;
            }
        }
        return $ei;
    }
}

sub is_soper {
    my ($uid) = @_;
    my $return = 0;
    my @sopers = split( " ", config( 'operators', 'sra' ) );
    foreach my $soper (@sopers) {
        if ( uidInfo( $uid, 9 ) ) {
            if ( uidInfo( $uid, 7 ) and uidInfo( $uid, 9 ) eq $soper ) {
                $return = 1;
            }
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
    if ( defined $Chakora::uid{$user}{'account'} ) {
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

sub ison {
	my ($user, $chan) = @_;
	my $return = 0;
	if (defined(uidInfo($user, 10))) {
		my @chan = split(' ', uidInfo($user, 10));
		foreach my $c (@chan) {
			if (lc($c) eq lc($chan)) {
				$return = 1;
			}
		}
	}
	return $return;
}

sub svsilog {
    my ( $service, $user, $cmd, $args ) = @_;
    if ( !uidInfo( $user, 9 ) ) { $user = uidInfo( $user, 1 ); }
    else { $user = uidInfo( $user, 1 ) . " (" . uidInfo( $user, 9 ) . ")"; }
    if ( length($args) == 0 ) {
        serv_privmsg(
            $service,
            config( 'log', 'logchan' ),
            "$user: \002" . uc($cmd) . "\002"
        );
    }
    else {
        serv_privmsg(
            $service,
            config( 'log', 'logchan' ),
            "$user: \002" . uc($cmd) . "\002: " . $args
        );
    }
}

sub logchan {
    my ( $service, $text ) = @_;
    serv_privmsg( $service, config( 'log', 'logchan' ), $text );
}

sub gen_sid {
	my ($try) = @_;
	if ($try > 4) {
		return 0;
	}
        my ($match);
        my $n1 = int(rand(10));
        my $n2 = int(rand(10));
        my $n3 = int(rand(10));
        my $sid = $n1."".$n2."".$n3;
        foreach my $key (keys %Chakora::sid) {
                if ($Chakora::sid{$key}{sid} eq $sid) {
                        $match = 1;
                }
        }
        if ($match) {
		$try++;
                gen_sid($try);
        }
        else {
                return $sid;
        }
}




1;

