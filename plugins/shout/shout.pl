# Plugin to 'shout' using megaphone [Cydh]
package shout;

use Plugins;
use Log qw(warning message error);
use Globals;

use constant {
	PLUGINNAME  => "shout",
	PLUGINDESC  => "Shout a text after using item as Megaphones",
};

my $megaphone_consumed;
# Items identified as Megaphones
my @megaphones = (12221);

# Plugin
Plugins::register(PLUGINNAME, PLUGINDESC, \&unload);

my $chooks = Commands::register(
	['shout', "Send 'talk text' after using Megaphone", \&cmdShoutText],
);

my $hooks = Plugins::addHooks(
	['packet_useitem', \&onItemRemoved],
);

# Plugin unload
sub unload {
	message "Unloading ".PLUGINNAME." - ".PLUGINDESC.".\n", "info";
	$megaphone_consumed = 0;
	Plugins::delHooks($hooks);
	Commands::unregister($chooks);
}

sub onItemRemoved {
	my ($self, $args) = @_;
	my $item = $args->{item};
	if ($item && grep { $item->{nameID} eq $_ } @megaphones) {
		$megaphone_consumed = 1;
		message "Item identified as Megaphone is consumed. Use shout <type the message here> to continue.\n", "info";
	}
	return 0;
}

# shout <message>
sub cmdShoutText {
	my ($command, $arg1) = @_;

	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", $command);
		return;
	}

	if ($megaphone_consumed != 1 || $arg1 eq "") {
		error "You need to use item [Megaphone] before using this command.\nUsage: shout <type the message here>\n";
	} else {
		$megaphone_consumed = 0;
		message "Text to shout: ".$arg1."\n";
		$messageSender->sendTalkText(undef, $arg1);
	}
	return 0;
}

1;
