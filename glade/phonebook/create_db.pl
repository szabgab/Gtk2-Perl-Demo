use strict;
use warnings;
use Acme::MetaSyntactic qw(flintstones buffy);


use DBI;
my $dbfile = "phonebook.db";
unlink $dbfile;
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
my $sqls = join "", <DATA>;
foreach my $sql (split /;/, $sqls) {
	next if $sql !~ /\S/;
	$dbh->do("$sql;");
}

for (1..10) {
	$dbh->do("INSERT INTO names (name, phone) VALUES (?,  ?)", 
		undef, metaname(), int rand(899999)+100000);
}
	

__DATA__
CREATE TABLE names (
	id    INTEGER PRIMARY KEY,
	name  VARCHAR(100),
	phone VARCHAR(100)
);

