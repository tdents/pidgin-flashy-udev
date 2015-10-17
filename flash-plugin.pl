use Thread qw(yield async);
use Purple;
use Time::HiRes qw (sleep);

our $idVendor=`cat /etc/pidgin-flashy.conf | grep -v -e '^#' | grep 'dVendor' | cut -d '=' -f2`;
chomp($idVendor);
our $idProduct=`cat /etc/pidgin-flashy.conf | grep -v -e '^#' | grep 'dProduct' | cut -d '=' -f2`;
chomp($idProduct);

###
%PLUGIN_INFO = (
	perl_api_version => 2,
	name => "FlashyLightPlugin",
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
        my $devicepath=getdevicepath();
        if(lenght($devicepath) > 0) {
        	my $devicepowerlevel="$devicepath/power/level";
		open OUTPUT, ">$devicepowerlevel";
		print OUTPUT "on";
		close OUTPUT;
        }
}

sub off {
	my $devicepath=getdevicepath();
	if(lenght($devicepath) > 0) {
		my $devicepowerlevel="$devicepath/power/level";
		open OUTPUT, ">$devicepowerlevel";
        	print OUTPUT "auto";
        	close OUTPUT;
	}
}

sub getdevicepath {
        our $devicepath=`udevadm trigger -v -a idVendor=$idVendor -a idProduct=$idProduct`;
        chomp($devicepath);
	return $devicepath;
}

sub plugin_load {
	my $plugin = shift;
	
	$t=async {
		for ($exitapp; $exitapp > -1; $exitapp)
		{
			Time::HiRes::sleep (0.1);
			my $unread = total_unread_count();
			if(total_unread_count() > 0) {
			on();
			Time::HiRes::sleep (0.5);
			off();
			Time::HiRes::sleep (0.5);
                }
        } 
};

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
	my $unread = total_unread_count();
}

sub plugin_unload {
	my $plugin = shift;
}
