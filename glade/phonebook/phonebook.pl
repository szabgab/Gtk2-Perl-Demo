use strict;
use warnings;

use Gtk2 -init;
use Gtk2::GladeXML;
use Gtk2::Ex::DBI;
use Phonebook;
use DBI;
my $dbfile = "phonebook.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");


my $gladexml = Gtk2::GladeXML->new("phonebook.glade", "names");
my $data_handler = Gtk2::Ex::DBI->new( { 
	dbh         => $dbh, 
	table       => "names", 
	primarykey  => "id",
	sql_select  => "select *", 
	#sql_where   => "where Actve=1", 
	form        => $gladexml, 
	formname    => "names", 
	on_current  => \&_current, 
	calc_fields => { 
		calc_total => 'eval { 
				$self->{form}->get_widget("value_1")->get_text + 
				$self->{form}->get_widget("value_2")->get_text }' 
	}, 
	default_values => { 
			ContractYears => 5, 
			Fee => 2000 
	} 
});

sub _current {
	print "Current\n";
	# I get called when moving from one record to another ( see on_current key, above ) 
}

#my $gladexml = Gtk2::GladeXML->new("phonebook.glade");
#$gladexml->signal_autoconnect_from_package("Phonebook");
#Gtk2->main;



