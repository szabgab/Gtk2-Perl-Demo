use strict;
use warnings;

use Gtk2 -init;
use Gtk2::GladeXML;
use Phone;
use DBI;

my $gladexml = Gtk2::GladeXML->new("phonebook.glade");
$gladexml->signal_autoconnect_from_package("Phone");
Phone->new($gladexml);

Gtk2->main;



