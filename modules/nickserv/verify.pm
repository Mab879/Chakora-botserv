# nickserv/verify by Franklin IRC Services. Allows opers with nickserv:override to force verification.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("nickserv/verify", "The Chakora Project", "0.1", \&init_ns_register, \&void_ns_register);

sub init_ns_register {
	if (!module_exists("nickserv/main")) {
		module_load("nickserv/main");
	}

	cmd_add("nickserv/verify", "Allow opers to force verification.", "VERIFY allow opers with nickserv:override to force verification on account that are not verifyed");
      }
sub void_ns_verify {
  delete_sub 'init_ns_verify';
  delete_sub 'svs_ns_verify';
}
sub svs_ns_verify {
  my ($user, @sargv) = @_;
  if (has_spower($user, 'nickserv:override')) {
    
    if (!defined($sargv[1])) {
      serv_notice("nickserv" , $user, "Not enough parameters: Syntax: VERIFY <acccount name>");
      return;
		}
   
    if (!uidInfo($user, 9)) {
      serv_notice("nickserv" , $user, "You must be logged in to perform this operation.");
}
    if (!defined Chakora::DB_account{lc($sargv[1])}{name} {
      serv_notice("nickserv" , $user, "Account \002$sargv[1]\002 doesn't exist!");
}
	if (defined Chakora::DB_account{
    else {
      serv_notice("nickserv" , $user, "You don't have permession to this operation.");
  return;
}
