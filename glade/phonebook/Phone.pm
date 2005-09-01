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

sub on_save_clicked {
	my $name = $glade->get_widget('name')->get_text;
	my $phone = $glade->get_widget('phone')->get_text;
	$dbh->do("INSERT INTO names (name, phone) VALUES(?,?)",
		undef,
		$name, $phone);
	find_id($dbh->func('last_insert_rowid'));
}

sub on_find_clicked {
	
}
sub find_id {
	my ($id) = @_;
	my $sth = $dbh->prepare("SELECT id, name, phone FROM names WHERE id =?");
	$sth->execute($id);
	my $h = $sth->fetchrow_hashref;
	$sth->finish;
	display($h);
}

sub on_first_clicked {
	show_first(@_);
}

sub on_prev_clicked {
	fetch("prev");	
}
sub on_next_clicked {
	fetch("next");	
}
sub on_last_clicked {
	fetch("last");	
}
sub on_new_clicked {
	display({});
	#$glade->get_widget($_)->set_text('') foreach (qw(id name phone));
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
	if ($which eq "prev") {
		$h = $sth->fetchrow_hashref;
		if ($h->{id} != $id) {
			while (my $next = $sth->fetchrow_hashref) {
				last if $next->{id} == $id;
				$h = $next;
			}
		}
	}
	if ($which eq "last") {
		$h = $sth->fetchrow_hashref;
		while (my $next = $sth->fetchrow_hashref) {
			$h = $next;
		}
	}

	$sth->finish;
	display($h);
}

sub display {
	my ($h) = @_;
	$glade->get_widget($_)->set_text($h->{$_} || '') foreach (qw(id name phone));
}


1;

