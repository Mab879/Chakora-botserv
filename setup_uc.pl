#!/usr/bin/perl
#
# /  __ \ |         | |                  
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#             Setup Wizard
#
# Setup wizard for Chakora

print("/  __ \ |         | |                   \n");
print("| /  \/ |__   __ _| | _____  _ __ __ _  \n");
print("| |   | '_ \ / _` | |/ / _ \| '__/ _` | \n");
print("| \__/\ | | | (_| |   < (_) | | | (_| | \n");
print(" \____/_| |_|\__,_|_|\_\___/|_|  \__,_| \n");
print("             SETUP WIZARD               \n");
print("\n");
print("Yes hello. Welcome to the Chakora Setup Wizard!\n");
print("We recommend using this to make sure everything works\n");
print("properly.\n");
print("\n"); sleep 3;
print("Checking for required modules...\n"); sleep 2;

my ($die);

print "Checking for IO::Socket..... "; 
eval {
	require IO::Socket;
	print "OK\n";
	1;
} or print("Not Found (install IO::Socket)\n") and $die = 1;

print("Checking for Config::Scoped..... ");
eval {
	require Config::Scoped;
	print "OK\n";
	1;
} or print("Not Found (install Config::Scoped)\n") and $die = 1;

print("Checking for DBI..... ");
eval {
	require DBI;
	print "OK\n";
	1;
} or print("Not Found (install DBI)\n") and $die = 1;

print("Checking for DBD::CSV..... ");
eval {
	require DBD::CSV;
	print "OK\n";
	1;
} or print("Not Found (install DBD::CSV)\n") and $die = 1;

print("Checking for FindBin..... ");
eval {
	require FindBin;
	print "OK\n";
	1;
} or print("Not Found (install FindBin)\n") and $die = 1;

print("Checking for File::Data..... ");
eval {
	require File::Data;
	print "OK\n";
	1;
} or print("Not Found (install File::Data)\n") and $die = 1;

print("Checking for Term::Prompt..... ");
eval {
	require Term::Prompt;
	print "OK\n";
	1;
} or print("Not Found (install Term::Prompt)\n") and $die = 1;

print("\n");

if ($die == 1) {
	die("Required modules missing! Please install these then try again!\n");
}

print("Alright, sparky! All required modules were found!\nStarting configuration generator...\n\n"); sleep 2;

if ($die != 1) {
#	use Term::Prompt;
}

`mkdir etc`;
my $file = './etc/chakora.conf';
`touch $file`;

my $conf = File::Data->new($file);

$conf->prepend("# Chakora configuration file\n");
$conf->append("\n\nme {\n");

my $name = prompt('x', 'What is the linkname for this server?', 'eg. some.server.tld', '');
print("\n");
$conf->append("\tname = ".$name."\n");

my $info = prompt('x', 'What should be the description for this server?', '', 'Chakora IRC Services');
print("\n");
$conf->append("\t".'info = "'.$info."\"\n");

my $sid = prompt('x', 'What should be the SID for this server?', '', '34R');
print("\n");
$conf->append("\tname = ".$sid."\n");

$conf->append("}\n\nserver {\n");

my $ircd = prompt('a', 'What is the IRCd of the remote server?', 'inspircd or charybdis', 'inspircd');
print("\n");
$conf->append("\tircd = ".$ircd."\n");

my $host = prompt('x', 'What is the hostname of the remote server?', 'eg. some.server.tld', '');
print("\n");
$conf->append("\thost = ".$host."\n");

my $vhost = prompt('x', 'What should be the vHost of this server?', 'Mainly for multi-homed hosts.', '127.0.0.1');
print("\n");
$conf->append("\tvhost = ".$vhost."\n");

my $port = prompt('n', 'What port shall we connect on?', '', '7000');
print("\n");
$conf->append("\tport = ".$port."\n");

my $pass = prompt('x', 'What is the linkpass for this server?', '', 'linkage');
print("\n");
$conf->append("\tpassword = ".$pass."\n");

$conf->append("}\n\nnetwork {\n");

my $name = prompt('x', 'What is the name of the network we are linking to?', '', 'freenode');
print("\n");
$conf->append("\t".'name = "'.$name."\"\n");

my $admin = prompt('x', 'Who is the admin of these services?', '', 'starcoder');
print("\n");
$conf->append("\t".'admin = "'.$admin."\"\n");

$conf->append("}\n\nlog {\n\n");

$conf->append("\t/*\n");
$conf->append("\t* Logging flags:\n");
$conf->append("\t* 	debug - Log all debug\n");
$conf->append("\t* 	commands - Log all command usuage\n");
$conf->append("\t* 	error - Log critical errors\n");
$conf->append("\t* 	set - Log all SET commands for an user/channel\n");
$conf->append("\t*	register - Log all registrations\n");
$conf->append("\t*	soper - Log all service oper usuage\n");
$conf->append("\t*	request - Logs anything thats requested (mainly vHosts)\n");
$conf->append("\t*/\n");
$conf->append("\t# Logs registrations and use of the SET command.\n");
$conf->append("\tlogfile \"var/user.log\" [ register; set; };\n");
$conf->append("\n");
$conf->append("\t# Logs all command usuage.\n");
$conf->append("\tlogfile \"var/cmds.log\" { commands; };\n");
$conf->append("\n");
$conf->append("\t# An example of a log channel.\n");
$conf->append("\tlogfile \"#services\" { error; soper; request; register; };\n");

$conf->append("}\n\n");

my $svs = 'ChanServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Channel Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\tnick = ".$host."\n");
$conf->append("\thost = \"".$real."\"\n}\n\n");

my $svs = 'NickServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Nickname Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\tnick = ".$host."\n");
$conf->append("\thost = \"".$real."\"\n}\n\n");

my $svs = 'OperServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Oper Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\tnick = ".$host."\n");
$conf->append("\thost = \"".$real."\"\n}\n\n");

my $svs = 'HostServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "vHost Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\tnick = ".$host."\n");
$conf->append("\thost = \"".$real."\"\n}\n\n");

my $svs = 'MemoServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Memo Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\tnick = ".$host."\n");
$conf->append("\thost = \"".$real."\"\n}\n\n");

my $svs = 'Global';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Global Noticer");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\tnick = ".$host."\n");
$conf->append("\thost = \"".$real."\"\n}\n\n");

my $sras = prompt('x', 'Who should have SRA Status?', 'Separate nicks with spaces.', "starcoder MattB");
print("\n");
$conf->append("sra = \"".$sras."\"\n");

$conf->append("\n# End configuration file");

print("\nAll done! Please configure the logging portion of the config in\netc/chakora.conf then run ./bin/chakora to start her up!\n");
