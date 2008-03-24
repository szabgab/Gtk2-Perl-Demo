package App::Gtk2Demo;
use strict;
use warnings FATAL => 'all';

our $VERSION = '0.01';

use App::Gtk2Demo::Glade;
use Gtk2::GladeXML;

sub run {
    my $gladexml = Gtk2::GladeXML->new_from_buffer(App::Gtk2Demo::Glade::get_xml());
    $gladexml->signal_autoconnect_from_package("App::Gtk2Demo");
    Gtk2->main;
}
sub on_main_destroy {
    _close_app();
}
sub on_quit_clicked {
    _close_app();
}

AUTOLOAD {
    our $AUTOLOAD;
    print $AUTOLOAD . " <-\n";
}
sub DESTROY {
}


1;

