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

