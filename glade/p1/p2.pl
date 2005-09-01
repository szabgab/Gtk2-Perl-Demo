use Gtk2 -init;
use Gtk2::GladeXML;
use GP1;
$gladexml = Gtk2::GladeXML->new("p1.glade");
$gladexml->signal_autoconnect_from_package("GP1");
$quitbtn = $gladexml->get_widget("Quit");
Gtk2->main;


AUTOLOAD {
	print $AUTOLOAD . "\n";
}

