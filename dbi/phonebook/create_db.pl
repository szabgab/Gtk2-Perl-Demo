use strict;
use warnings;

use DBI;
my $dbfile = "phonebook.db";
unlink $dbfile;
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
my $sqls = join "", <DATA>;
foreach my $sql (split /;/, $sqls) {
	next if $sql !~ /\S/;
	$dbh->do("$sql;");
}




__DATA__
CREATE TABLE names (
	id    INTEGER PRIMARY KEY,
	name  VARCHAR(100),
	phone VARCHAR(100)
);
INSERT INTO names VALUES (1, "Gabor", 123);
INSERT INTO names VALUES (2, "Peter", 456);
INSERT INTO names VALUES (3, "Zoli", 23);


