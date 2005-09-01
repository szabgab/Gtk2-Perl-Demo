package Phone;
use strict;
use warnings;

use Data::Dumper;

my $glade;
my $dbh;
our $AUTOLOAD;

sub new {
	my $class = shift;
	$glade    = shift or die;
	my $dbfile = "phonebook.db";
	$dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","") or die;

	show_first();

	return bless {}, $class;
}


AUTOLOAD {
	print $AUTOLOAD ." in Phone\n";
	print Dumper @_;
}

sub on_main_window_destroy {
	exit;
}

sub on_add_click {
	my $name = $glade->get_widget('name')->get_text;
	my $phone = $glade->get_widget('phone')->get_text;
	$dbh->do("INSERT INTO names (name, phone) VALUES(?,?)",
		undef,
		$name, $phone);
	
}

sub on_first_clicked {
	show_first(@_);
}

sub on_prev_clicked {
}
sub on_next_clicked {
	fetch("next");	
}

sub show_first {
	fetch("first");
	
}

sub fetch {
	my ($which) = @_;
	my $sth = $dbh->prepare("SELECT id, name, phone FROM names");
	$sth->execute;
	my $h;
	my $id = $glade->get_widget('id')->get_text;
	if ($which eq "first") {
		$h = $sth->fetchrow_hashref;
	}
	if ($which eq "next") {
		while ($h = $sth->fetchrow_hashref) {
			if ($h->{id} == $id) {
				$h = $sth->fetchrow_hashref;
				last;
			}
		}
	}	
	$sth->finish;
	$glade->get_widget($_)->set_text($h->{$_}) foreach (qw(id name phone));
}



1;

