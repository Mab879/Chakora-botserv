# nickserv/register by The Chakora Project. Allows users to register their nickname with services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("nickserv/register", "The Chakora Project", "0.1", \&init_ns_register, \&void_ns_register);

sub init_ns_register {
	if (!module_exists("nickserv/main")) {
		module_load("nickserv/main");
	}
	cmd_add("nickserv/register", "Register a nickname with services.", "This will allow you to register your current nickname with ".config('nickserv', 'nick').".\nBy doing this you are creating an identity for yourself on the network,\nand allowing yourself to be added to access lists. ".config('nickserv', 'nick')." will also\nwarn users when using your nick, make them go unidentified if they don't\nidentify, and allow you to kill ghosts. The password is a case sensitive\npassword that you make up. Please write it down or memorize it! You will\nneed it to identify or change settings later on.\n[T]\nSyntax: REGISTER <password> <email-address>", \&svs_ns_register);
	hook_uid_add(\&ns_enforce_on_uid);
	hook_nick_add(\&ns_enforce_on_nick);
}

sub void_ns_register {
	hook_uid_del(\&ns_enforce_on_uid);
	hook_nick_add(\&ns_enforce_on_nick);
	delete_sub 'init_ns_register';
	delete_sub 'svs_ns_register';
	delete_sub 'ns_enforce_on_uid';
	delete_sub 'ns_enforce_on_nick';
	delete_sub 'ns_enforce';
	cmd_del("nickserv/register");
	delete_sub 'void_ns_register';
}

sub mkverifycode {
        my ($maxchars) = @_;
        my @letters = (
                'A','B','C','D','E','F','G','H','I','J','K',
                'L','M','N','O','P','Q','R','S','T','U','V',
                'W','X','Y','Z'
        );

        $maxchars = $maxchars / 2;

        my $alias;
        my ($x, $y);

        for (my $i = 0; $i < $maxchars; $i++) {
                $x = int(rand($#letters));
                $y = int(rand(9));
                if ($x % 2) {
                        $alias .= lc($letters[$x]);
                } else {
                        $alias .= $letters[$x];
                }
                $alias .= $y;
        }

        return $alias;
}

sub svs_ns_register {
	my ($user, @sargv) = @_;
	my $nick = uidInfo($user, 1);
	my $password = $sargv[1];
	my $email = $sargv[2];
	my $regtime = time();
	my $host = uidInfo($user, 2)."@".uidInfo($user, 4);
	my $ec = 0;
	foreach my $key (keys %Chakora::DB_account) {
		if ($ec == config('nickserv', 'max_email')) {
			serv_notice("nickserv", $user, "This email address has already been used the maximum number of times possible to register an account");
			return;
		}
		elsif (lc($Chakora::DB_account{$key}{email}) eq lc($email)) {
			$ec++;
		}	
	}
	unless (!defined($email) or !defined($password)) {
		unless (is_registered(1, $nick)) {
			unless (length($password) < 5) {
				unless (!Email::Valid->address($email)) {

if (config('nickserv', 'verify_email')) {
						unless (my $pid = fork) {
                                                        serv_notice("nickserv", $user, "An email containing nickname activation instructions has been sent to $email.");
							defined $pid or error('nickserv', 'Cannot fork to send verify email: '.$!);
							my $sendmail = config('sendmail', 'sendmail_path');
							my $verifycode = mkverifycode(20);
							my $mailtemplate = config('nickserv', 'verify_email_template');
							open (FH, $mailtemplate) or error('nickserv', 'cannot open email template');
							my @template = <FH>;
							close FH;
							my $email;
							foreach my $line (@template) {
								$line =~ s/\%account%/$user/gs;
								$line =~ s/\%verifycode%/$verifycode/gs;
								$email .= $line
							}
							open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!"; 
							print SENDMAIL "Reply-to: ".config('sendmail', 'reply_email')."\n";
							print SENDMAIL "Subject: Nick Registration Verification\n";
							print SENDMAIL "To: $email\n";
							print SENDMAIL "Content-type: text/plain\n\n"; 
							print SENDMAIL $email;
							close SENDMAIL;
							$Chakora::DB_account{lc($nick)}{email_verify_code} = $verifycode;
							exit;
						}
					}
			
					my $pass = hash($password);
					$Chakora::DB_account{lc($nick)}{name} = $nick;
					$Chakora::DB_account{lc($nick)}{pass} = $pass;
					$Chakora::DB_account{lc($nick)}{email} = $email;
					$Chakora::DB_account{lc($nick)}{regtime} = time();
					$Chakora::DB_account{lc($nick)}{lasthost} = $host;
					$Chakora::DB_account{lc($nick)}{lastseen} = time();
					$Chakora::DB_nick{lc($nick)}{nick} = $nick;
					$Chakora::DB_nick{lc($nick)}{account} = $nick;
					$Chakora::DB_nick{lc($nick)}{regtime} = time();
					metadata_add(1, $nick, "flag:enforce", 1);
					metadata_add(1, $nick, "flag:hidemail", 1);
					serv_accountname($user, $nick);
					$Chakora::uid{$user}{'account'} = $nick;
					svsilog("nickserv", $user, "REGISTER", "\002".$nick."\002 to \002".$email."\002");
					event_register($user, $email);
					serv_notice("nickserv", $user, "\2".$nick."\2 is now registered to \2".$email."\2 with the password \2".$password."\2");
					serv_notice("nickserv", $user, "Thank you for registering with ".config('network', 'name')."!");
				} else { serv_notice("nickserv", $user, 'Invalid email address.'); }
			} else { serv_notice("nickserv", $user, 'Your password must be at least 5 characters long.'); }
		} else { serv_notice("nickserv", $user, 'This nickname is already registered.'); }
	} else { serv_notice("nickserv", $user, 'Not enough parameters. Syntax: REGISTER <password> <email address>'); }
}

sub ns_enforce_on_uid {
	my ($uid, $nick, undef, undef, undef, undef, undef) = @_;
	
	if (defined $Chakora::DB_nick{lc($nick)}{account}) {
		my $account = $Chakora::DB_nick{lc($nick)}{account};
		if (!metadata(1, $account, "flag:enforce")) {
			return;
		}
		serv_notice("nickserv", $uid, "This nickname is registered and protected.  Please");
		serv_notice("nickserv", $uid, "identify with /msg ".$Chakora::svsnick{'nickserv'}." IDENTIFY <password>");
		serv_notice("nickserv", $uid, "within ".config('nickserv', 'enforce_delay')." seconds or I will change your nick.");
		#my $timer = POSIX::RT::Timer->new(value => config('nickserv', 'enforce_delay'), callback => sub {
		#	my $timer = shift;
		#	ns_enforce($uid, $account);
		#});
	}
}

sub ns_enforce_on_nick {
	my ($uid, $nick) = @_;
	
	if (defined $Chakora::DB_nick{lc($nick)}{account}) {
		my $account = $Chakora::DB_nick{lc($nick)}{account};
		if (!metadata(1, $account, "flag:enforce")) {
			return;
		}
		serv_notice("nickserv", $uid, "This nickname is registered and protected.  Please");
		serv_notice("nickserv", $uid, "identify with /msg ".$Chakora::svsnick{'nickserv'}." IDENTIFY <password>");
		serv_notice("nickserv", $uid, "within ".config('nickserv', 'enforce_delay')." seconds or I will change your nick.");
		#my $timer = Timer->new;
		#$timer->addonce(code => \&ns_enforce, data => "$uid $account", config('nickserv', 'enforce_delay'));
		#sleep 1 while $timer->run;
#		sleep config('nickserv', 'enforce_delay');
#		ns_enforce($uid, $account);
	}
}

sub ns_enforce {
	my ($user, $account) = @_;
#	my ($udata) = @_;
#	my @ud = split(' ', $udata);
#	my $account = $ud[1]; my $user = $ud[0];
	if (!uidInfo($user, 9) or uidInfo($user, 9) ne $account) {
		serv_notice("nickserv", $user, "You failed to identify in time.");
		serv_enforce($user, "Guest-".int(rand(99999)));
	}
}
