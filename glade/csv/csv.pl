use strict;
use warnings;

use Gtk2 -init;
use Gtk2::GladeXML;
use Csv;
use Text::CSV_XS;

my $gladexml = Gtk2::GladeXML->new("csv.glade");
$gladexml->signal_autoconnect_from_package("Csv");
my $csv = Csv->new($gladexml);
$gladexml->get_widget('opendialog')->hide;
$csv->init;

Gtk2->main;



