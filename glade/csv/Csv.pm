package Csv;
use strict;
use warnings;

my $glade;

sub new {
	my $class = shift;
	$glade    = shift;
	my $self = bless {}, $class;
}
sub init {
	my ($self) = @_;
	my $holder = $glade->get_widget('scrolledwindow');
	my ($ROWS, $COLS) = (2, 4);
	my $spreadsheet = Gtk2::Table->new($ROWS, $COLS);
	foreach my $x (1..$ROWS) {
		foreach my $y (1..$COLS) {
			my $entry = Gtk2::Entry->new;
			$spreadsheet->attach_defaults($entry, $x-1, $x, $y-1, $y);
		}
	}
	$holder->add($spreadsheet);
	$spreadsheet->show_all;
}
our $AUTOLOAD;

AUTOLOAD {
	print "Csv: $AUTOLOAD\n";
}
DESTROY {
}


sub on_open1_activate {
}

sub on_window_destroy { quit();}
sub on_quit1_activate { quit();}
sub quit {
	Gtk2->main_quit;
}
1;

