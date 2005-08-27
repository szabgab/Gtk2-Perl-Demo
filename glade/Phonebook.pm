package Phonebook;


AUTOLOAD {
	print $AUTOLOAD ." in Phonebook\n";
}

sub on_main_window_destroy {
	exit;
}



1;

