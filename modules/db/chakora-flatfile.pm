# db/chakora-flatfile by The Chakora Project. Database backend module for Chakora1.0-Flatfile.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("db/chakora-flatfile", "The Chakora Project", "1.0.2", \&init_db, \&void_db);

sub init_db {
	if (defined $Chakora::DB_VERSION) {
		svsflog("chakora", "Unloading database backend: $Chakora::DB_VERSION");
		undef $Chakora::DB_VERSION;
	}
	$Chakora::DB_VERSION = "Chakora1.0-Flatfile";
	svsflog("chakora", "Initializing database backend: $Chakora::DB_VERSION");
	return 1;
}

sub void_db {
	svsflog("chakora", "Unloading database backend: $Chakora::DB_VERSION");
	undef $Chakora::DB_VERSION;
	delete_sub 'init_db';
	delete_sub 'db_flush';
	delete_sub 'void_db';
	delete_sub 'db_delete';
	delete_sub 'db_find';
	delete_sub 'db_write';
	delete_sub 'db_read';
}

sub db_flush {
    unless ( -e "$Chakora::ROOT_SRC/../etc/chakora.db" ) {
        `touch $Chakora::ROOT_SRC/../etc/chakora.db`;
    }
    open FILE, ">$Chakora::ROOT_SRC/../etc/chakora.db" or return 0;
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
	      . $Chakora::DB_chan{$key}{bot} . "" 	
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
		foreach my $key ( keys %Chakora::DB_bot) {
		  unless (!defined($Chakora::DB_bots{key}{realname})) {
		    . $Chakora::DB_bots{$key}{username} . ""
		    . $Chakora::DB_bots{$key}{name} . ""
		    . $Chakora::DB_bots{$key}{host} . ""
		    . $Chakora::DB_bots{key}{realname} . "/n";
		  }
		      
    }
    print FILE $dd;
    close FILE;
    return 1;
}

sub db_read {
	
}

sub db_find {
	
}

sub db_write {
	
}

sub db_delete {
	
}
