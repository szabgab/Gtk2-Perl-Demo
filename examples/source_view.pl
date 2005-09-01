use strict;
use warnings;

# lifted directly from the documentation of Gtk2::SourceView
# Copyright 2004 by Emmanuele Bassi
#
# with some changes by Gabor Szabo
#

use Gtk2 '-init';
use Gtk2::SourceView;

my $lm = Gtk2::SourceView::LanguagesManager->new;
my $lang = $lm->get_language_from_mime_type("application/x-perl");
my $sb;
if ($lang) {
	$sb = Gtk2::SourceView::Buffer->new_with_language($lang);
	$sb->set_highlight(1);
} else {
	$sb = Gtk2::SourceView::Buffer->new(undef);
	$sb->set_highlight(0);
}

# loading a file should be atomically undoable.
$sb->begin_not_undoable_action();
open my $infile, $0 or die "Unable to open program.pl";
while (<$infile>) {
	$sb->insert($sb->get_end_iter(), $_);
}
$sb->end_not_undoable_action();

# Gtk2::SourceView::Buffer inherits from Gtk2::TextBuffer.
$sb->set_modified(0);
$sb->place_cursor($sb->get_start_iter());

my $win = Gtk2::Window->new("toplevel");
$win->signal_connect (destroy => sub { Gtk2->main_quit; });
$win->set_default_size(600, 650);
my $sw = Gtk2::ScrolledWindow->new;
$sw->set_policy("automatic", "automatic");
$win->add($sw);

# Gtk2::SourceView::View inherits from Gtk2::TextView.
my $view = Gtk2::SourceView::View->new_with_buffer($sb);
$sw->add($view);
$view->show;
$win->show_all;

Gtk2->main;


