#!/usr/bin/perl -w
use strict;
use warnings;

use lib "lib"; 
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';
use Gtk2::Ex::Datasheet::DBI;
use DBI;

my $dbfile = "phonebook.db";
die "Database file $dbfile does not exist\n" if not -e $dbfile;



my $window = Gtk2::Window->new;
$window->set_title("Phonebook");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $main_vbox = Gtk2::VBox->new();
$window->add($main_vbox);

#my $tree_store = Gtk2::TreeStore->new('Glib::String', 'Glib::String');
#my $tree_view  = Gtk2::TreeView->new($tree_store);
my $tree_view  = Gtk2::TreeView->new();
$main_vbox->add($tree_view);

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
my $datasheet_def = { 
	dbh          => $dbh, 
	table        => "names", 
	primary_key  => "id", 
	sql_select   => "select name, phone ", 
	sql_order_by => " order by name", 
	treeview     => $tree_view,
	fields       => [ 
		{ 
			name => "name", 
			x_percent => 35, 
			validation => sub { &validate_first_name(@_); } },
		{ 
			name => "phone", 
			x_percent => 60 }, 
	], 
	multi_select => TRUE 
};

my $data_sheet = Gtk2::Ex::Datasheet::DBI->new($datasheet_def) || die ("Error setting up Gtk2::Ex::Datasheet::DBI\n");


=pod
#$tree_view->signal_connect (button_release_event => \&button_release);
#$tree_view->signal_connect ("row-activated"      => \&execute_code);
my @cols = ("Name", "Phone");
my ($ENTRY_NAME, $ENTRY_PHONE) = (0, 1);
foreach my $i (0..1) {
	my $col = Gtk2::TreeViewColumn->new_with_attributes($cols[$i], Gtk2::CellRendererText->new(), text => $i);
	$tree_view->append_column($col);
}
$tree_view->set_headers_visible(1);
$main_vbox->add($tree_view);
$window->show_all();


my @entries = (
	["Gabor", 123],
	["Peter", 456],
);
foreach my $entry (@entries) {
	my $child = $tree_store->append(undef);
	$tree_store->set($child, 
		$ENTRY_NAME  => $entry->[0], 
		$ENTRY_PHONE => $entry->[1]);
}
=cut

$window->show_all;
Gtk2->main;

