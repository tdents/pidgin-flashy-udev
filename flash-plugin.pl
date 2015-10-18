use Thread qw(yield async);
use Purple;
use Time::HiRes qw (sleep);

our $idVendor=`cat /etc/pidgin-flashy.conf | grep -v '^#' | grep 'dVendor' | cut -d '=' -f2`;
chomp($idVendor);
our $idProduct=`cat /etc/pidgin-flashy.conf | grep -v '^#' | grep 'dProduct' | cut -d '=' -f2`;
chomp($idProduct);

###
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
	Purple::Debug::info("FlashyLightPlugin", "LEDPlugin on device: $devicepowerlevel\n");
	open OUTPUT, ">$devicepowerlevel";
	print OUTPUT "on";
	close OUTPUT;
}

sub off {
	Purple::Debug::info("FlashyLightPlugin", "LEDPlugin off device: $devicepowerlevel\n");
        open OUTPUT, ">$devicepowerlevel";
        print OUTPUT "auto";
        close OUTPUT;
}

sub startflash {
	async {
		our $devicepath=`udevadm trigger -v -a idVendor=$idVendor -a idProduct=$idProduct`;
		chomp($devicepath);
		Purple::Debug::info("FlashyLightPlugin", "LEDPlugin async start device: $devicepath\n");
		if(!$devicepath == '')
		{
			our $devicepowerlevel="$devicepath/power/level";
			for ($exitapp; total_unread_count() > 0; $exitapp)
			{
				$unread = total_unread_count();
				Purple::Debug::info("FlashyLightPlugin", "LEDPlugin cycle: $unread\n");
				on();
				Time::HiRes::sleep (0.5);
				off();
				Time::HiRes::sleep (0.5);
		        }
		}	
		Purple::Debug::info("FlashyLightPlugin", "LEDPlugin exit cycle\n");
	}
};

sub plugin_load {
        my $plugin = shift;

	my $conv_handle = Purple::Conversations::get_handle();
	
	Purple::Signal::connect($conv_handle, "received-im-msg", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "received-chat-msg", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "conversation-updated", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "conversation-created", $plugin, \&update_unread_count, '');
	Purple::Signal::connect($conv_handle, "deleting-conversation", $plugin, \&update_unread_count, '');
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
	my $unread = total_unread_count();
	if($unread > 0) { startflash(); };
}

sub plugin_unload {
	my $plugin = shift;
}
