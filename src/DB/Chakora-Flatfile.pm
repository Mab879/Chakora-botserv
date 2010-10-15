# db/chakora-flatfile by The Chakora Project. Database backend module for Chakora1.0-Flatfile.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

sub db_flush {
    unless ( -e "$ROOT_SRC/../etc/chakora.db" ) {
        `touch $ROOT_SRC/../etc/chakora.db`;
    }
    open FILE, ">$ROOT_SRC/../etc/chakora.db" or return 0;
    my $dd = "DBV Chakora1.0-Flatfile\n";
    foreach my $key ( keys %Chakora::DB_account ) {
		unless (!defined($Chakora::DB_account{$key}{name})) {
			$dd .= "AI "
			. $Chakora::DB_account{$key}{name} . " "
			. $Chakora::DB_account{$key}{pass} . " "
			. $Chakora::DB_account{$key}{email} . " "
			. $Chakora::DB_account{$key}{regtime} . " "
			. $Chakora::DB_account{$key}{lasthost} . " "
			. $Chakora::DB_account{$key}{lastseen} . "\n";
		}
    }
    foreach my $key ( keys %Chakora::DB_nick ) {
        unless ( !defined( $Chakora::DB_nick{$key}{nick} ) )
        {
            $dd .= "AN "
              . $Chakora::DB_nick{$key}{nick} . " "
              . $Chakora::DB_nick{$key}{account} . " "
              . $Chakora::DB_nick{$key}{regtime} . "\n";
        }
    }
    foreach my $key ( keys %Chakora::DB_accdata ) {
		unless (!defined($Chakora::DB_accdata{$key}{account})) {
			$dd .= "AD "
			. $Chakora::DB_accdata{$key}{account} . " "
			. $Chakora::DB_accdata{$key}{name} . " "
			. $Chakora::DB_accdata{$key}{value} . "\n";
		}
    }
    foreach my $key ( keys %Chakora::DB_chan ) {
        unless ( !defined( $Chakora::DB_chan{$key}{name} ) ) {
            $dd .= "CI "
              . $Chakora::DB_chan{$key}{name} . " "
              . $Chakora::DB_chan{$key}{founder} . " "
              . $Chakora::DB_chan{$key}{regtime} . " "
              . $Chakora::DB_chan{$key}{mlock} . " "
              . $Chakora::DB_chan{$key}{ts} . " "
              . $Chakora::DB_chan{$key}{desc} . "\n";
        }
    }
    foreach my $key ( keys %Chakora::DB_chandata ) {
		unless (!defined($Chakora::DB_chandata{$key}{value})) {
			$dd .= "CD "
			. $Chakora::DB_chandata{$key}{chan} . " "
			. $Chakora::DB_chandata{$key}{name} . " "
			. $Chakora::DB_chandata{$key}{value} . "\n";
		}
    }
    foreach my $key ( keys %Chakora::DB_chanflags ) {
		unless ( !defined( $Chakora::DB_chanflags{$key}{flags} ) ) {
        	$dd .= "CF "
          	. $Chakora::DB_chanflags{$key}{chan} . " "
          	. $Chakora::DB_chanflags{$key}{account} . " "
			. $Chakora::DB_chanflags{$key}{flags} . "\n";
		}
    }
    foreach my $key ( keys %Chakora::DB_memo ) {
		unless (!defined($Chakora::DB_memo{$key}{body})) {
			$dd .= "MM "
			. $Chakora::DB_memo{$key}{to} . " "
			. $Chakora::DB_memo{$key}{from} . " "
			. $Chakora::DB_memo{$key}{time} . " "
			. $Chakora::DB_memo{$key}{new} . " "
			. $Chakora::DB_memo{$key}{body} . "\n";
		}
    }
    print FILE $dd;
    close FILE;
    return 1;
}
