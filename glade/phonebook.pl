use Gtk2 -init;
use Gtk2::GladeXML;
use GP1;
$gladexml = Gtk2::GladeXML->new("phonebook/phonebook.glade");
$gladexml->signal_autoconnect_from_package("Phonebook");
#$quitbtn = $gladexml->get_widget("Quit");
Gtk2->main;


