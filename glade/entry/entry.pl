use Gtk2 -init;
use Gtk2::GladeXML;
my $gladexml = Gtk2::GladeXML->new("entry.glade");
$gladexml->signal_autoconnect_from_package("main");
Gtk2->main;


AUTOLOAD {
	print $AUTOLOAD . "\n";
}

sub on_main_window_destroy {
	Gtk2->main_quit;
}

