use Thread qw(yield async);
use Purple;
use IO::Socket::INET;

###
our $exitapp = 0;
our $unread = 0;

%PLUGIN_INFO = (
	perl_api_version => 2,
	name => "FlashyLightPlugin2",
	version => "1.0",
	summary => "Flashing LED connected to USB port",
	description => "Changes value in /var/flash/status",
	author => "Me",
	url => "http://localhost/",
	load => "plugin_load",
	unload => "plugin_unload"
);

sub plugin_init {
	return %PLUGIN_INFO;
}
sub on {
	Purple::Debug::info("FlashyLightPlugin2", "LEDPlugin on: $devicepowerlevel \n");
	open OUTPUT, ">$devicepowerlevel";
	print OUTPUT "on";
	close OUTPUT;
}

sub off {
	Purple::Debug::info("FlashyLightPlugin2", "LEDPlugin off: $devicepowerlevel \n");
        open OUTPUT, ">$devicepowerlevel";
        print OUTPUT "auto";
        close OUTPUT;
}


#$thr = async {
$thr = async {
	Purple::Debug::info("FlashyLightPlugin2", "LEDPlugin thread start\n");
	for ($exitapp;$exitapp='-1';$exitapp) 
	{
		sleep 1000;
		Purple::Debug::info("FlashyLightPlugin2", "LEDPlugin thread: $unread\n");
		if($unread > 0) {
			on();
			sleep 1000;
			off();
			sleep 1000;
		}
	}
};



sub plugin_load {
	my $plugin = shift;
        our $devicepath=`udevadm trigger -v -a idVendor=09da -a idProduct=0006`;
	chomp($devicepath);
        our $devicepowerlevel="$devicepath/power/level";
        Purple::Debug::info("FlashyLightPlugin2", "LEDPlugin device path: $devicepowerlevel \n");

	my $conv_handle = Purple::Conversations::get_handle();
	
	Purple::Signal::connect($conv_handle, "received-im-msg", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "received-chat-msg", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "conversation-updated", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "conversation-created", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "deleting-conversation", $plugin, \&update_unread_count, '');
	off();
}

sub total_unread_count {
	my $total_unread = 0;
	my @convs = Purple::get_conversations();

	for my $conv (@convs) {
		my $data = $conv->get_data('unseen-count');
		next unless defined($data);
		my $this_unread = $data->{_purple};
		$total_unread += $this_unread;
	}
	return $total_unread;
}

sub update_unread_count {
	our $unread = total_unread_count();
#	if($unread > 0) { 
#		on();
#	}
#	if($unread == 0) {
#		off();
#	}
}

sub plugin_unload {
	my $plugin = shift;
}
