use strict;
use warnings;

use DBI;
my $dbfile = "phonebook.db";
unlink $dbfile;
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
my $sql = join "", <DATA>;
$dbh->do($sql);




__DATA__
CREATE TABLE names (
	id    INTEGER PRIMARY KEY,
	name  VARCHAR(100),
	phone VARCHAR(100)
);


