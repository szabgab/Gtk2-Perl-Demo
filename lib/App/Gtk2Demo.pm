package App::Gtk2Demo;
use strict;
use warnings;

our $VERSION = '0.05';

use App::Gtk2Demo::GUI;

sub run {
    App::Gtk2Demo::GUI::build_gui;

}

#use Gtk2::GladeXML;
#
#my $gladexml;
#sub run {
#    require App::Gtk2Demo::Glade;
#    $gladexml = Gtk2::GladeXML->new_from_buffer(App::Gtk2Demo::Glade::get_xml());
#    $gladexml->signal_autoconnect_from_package("App::Gtk2Demo");
#    Gtk2->main;
#}
#sub on_main_destroy {
#    _close_app();
#}
#sub on_quit_clicked {
#    _close_app();
#}
#
#AUTOLOAD {
#    our $AUTOLOAD;
#    print $AUTOLOAD . " <-\n";
#}
#sub DESTROY {
#}


1;

