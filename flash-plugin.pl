use Thread;
use threads;
use threads::shared;
use Purple;
use Time::HiRes qw (sleep);

$cfgfile='/etc/pidgin-flashy.conf';
open CONFIG, "$cfgfile" or die "Program stopping, couldn't open the configuration file '$config_file'.\n";

while (<CONFIG>) {
    chomp; s/#.*//; s/^\s+//; s/\s+$//; next unless length;
    my ($var, $value) = split(/\s*=\s*/, $_, 2);
    $User_Preferences{$var} = $value;
}
our $idVendor = $User_Preferences{idVendor};
our $idProduct = $User_Preferences{idProduct};

###
%PLUGIN_INFO = (
	perl_api_version => 2,
	name => "FlashyLightPlugin",
	version => "1.0",
	summary => "Flashing LED connected to USB port",
	description => "USB Flashing plugin for UDEV",
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
	$t = Thread->new( sub {
		our $devicepath=`udevadm trigger -v -a idVendor=$idVendor -a idProduct=$idProduct`;
		chomp($devicepath);
		Purple::Debug::info("FlashyLightPlugin", "LEDPlugin thread start device: $devicepath\n");
		if(!$devicepath == '')
			{
			our $devicepowerlevel="$devicepath/power/level";
			for ($exitapp; total_unread_count() > 0; $exitapp)
				{
				$unread = total_unread_count();
				Purple::Debug::info("FlashyLightPlugin", "LEDPlugin cycle unread messages: $unread\n");
				on();
				Time::HiRes::sleep (0.5);
				off();
				Time::HiRes::sleep (0.5);
			        }
			}
		Purple::Debug::info("FlashyLightPlugin", "LEDPlugin exit cycle\n");
		}
	);
};

sub plugin_load {
        my $plugin = shift;
	our $threads=0;
	our $max_threads=1;
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
	$count=0;
	my $unread = total_unread_count();
	if($unread = 1) {
		for my $thr ( threads->list() ) {
			if($thr->tid) { $count++; 
				if ($thr->is_joinable ) { $thr->join(); }
			}
		}

		Purple::Debug::info("FlashyLightPlugin", "LEDPlugin threads: $count\n");		
	if($count < 1) { startflash(); }
	}
}

sub plugin_unload {
	my $plugin = shift;
}
