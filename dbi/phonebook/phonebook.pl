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

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {AutoCommit => 1});
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
			validation => sub { &validate_name(@_); } },
		{
			name => "phone",
			x_percent => 60 },
	],
	multi_select => TRUE
};

my $data_sheet = Gtk2::Ex::Datasheet::DBI->new($datasheet_def) || die ("Error setting up Gtk2::Ex::Datasheet::DBI\n");

my $buttons = Gtk2::HBox->new();
$main_vbox->add($buttons);

my $add_button = Gtk2::Button->new_from_stock('gtk-add');
$add_button->signal_connect (clicked => \&on_btn_add_clicked);
$buttons->add($add_button);

my $del_button = Gtk2::Button->new_from_stock('gtk-delete');
$del_button->signal_connect (clicked => \&on_btn_delete_clicked);
$buttons->add($del_button);

my $apply_button = Gtk2::Button->new_from_stock('gtk-apply');
$apply_button->signal_connect (clicked => \&on_btn_apply_clicked);
$buttons->add($apply_button);


sub on_btn_add_clicked {
	$data_sheet->insert( );
	#$data_sheet->insert( $data_sheet->column_from_name("GroupNo") => 1 );

}
sub validate_name {
	return 1;
}

sub on_btn_apply_clicked {

	$data_sheet->apply;
}

sub on_btn_delete_clicked {
	$data_sheet->delete;

}


$window->show_all;
Gtk2->main;


