#!/usr/bin/perl -w
use strict;
use warnings;
 
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';
use Data::Dumper;
use File::Temp qw(tempfile);

our $VERSION = '0.02';
my ($ENTRY_NAME, $ENTRY_TYPE, $ENTRY_FILE) = (0, 1, 2);

my @entries = do "entries.pl"; 
if (@ARGV and $ARGV[0] eq "check") {
	check_files(\@entries);
	print "All the files are readable\n";
	exit;
}

my $title = "GTK+ Perl binding Tutorial and code demos";
my %files;
my %widgets;
my $current_list;
collect_widgets(\@entries);
 
##### Main window
my $window = Gtk2::Window->new;
$window->set_title($title);
$window->signal_connect (destroy => sub { Gtk2->main_quit; });
$window->set_default_size(900, 650);

###### Main box
my $main_vbox = Gtk2::VBox->new();
$window->add($main_vbox);


##### Menu row
my $menu_row = Gtk2::HBox->new();
$main_vbox->pack_start($menu_row, FALSE, FALSE, 5);

my $toggle_button = Gtk2::Button->new("List Widgets");
$toggle_button->signal_connect(clicked=> \&toggle_list);
$menu_row->pack_start($toggle_button, FALSE, FALSE, 5);

my $execute_button = Gtk2::Button->new_from_stock('gtk-execute');
$execute_button->signal_connect(clicked=> \&execute_code);
$menu_row->pack_start($execute_button, FALSE, FALSE, 5);

my $save_button = Gtk2::Button->new_from_stock('gtk-save');
$save_button->signal_connect(clicked=> \&save_code);
$menu_row->pack_start($save_button, FALSE, FALSE, 5);

my $search_entry = Gtk2::Entry->new;
$search_entry->set_activates_default (TRUE);
$menu_row->pack_start($search_entry, FALSE, FALSE, 5);
#$search_entry->signal_connect ('insert-text' => sub {
#		my ($widget, $string, $len, $position) = @_;
#		#$window->set_default($search_button);
#		return();
#});

#### Radio buttons
my $radio_buttons = Gtk2::HBox->new();
$menu_row->pack_start($radio_buttons, FALSE, FALSE, 0);

my $button_all = Gtk2::RadioButton->new(undef, "All files");
$radio_buttons->pack_start($button_all, TRUE, TRUE, 0);
$button_all->set_active(TRUE);
$button_all->show;
my @group = $button_all->get_group;

my $button_buffer = Gtk2::RadioButton->new_with_label(@group, "Current buffer");
$radio_buttons->pack_start($button_buffer, TRUE, TRUE, 0);
$button_buffer->show;
###############

my $search_button = Gtk2::Button->new_from_stock('gtk-find');
$search_button->signal_connect(clicked=> \&search);
$menu_row->pack_start($search_button, FALSE, FALSE, 5);
$search_button->can_default(TRUE);
$window->set_default($search_button);



my $exit_button = Gtk2::Button->new_from_stock('gtk-quit');
$exit_button->signal_connect(clicked=> sub { Gtk2->main_quit; });
$menu_row->pack_end($exit_button, FALSE, FALSE, 5);

my $lower_pane = Gtk2::VPaned->new();
$main_vbox->pack_start($lower_pane, TRUE, TRUE, 5);


###### Left pane, file or Widget listing
my $hbox = Gtk2::HPaned->new();
$lower_pane->add1($hbox);

my $tree_store = Gtk2::TreeStore->new('Glib::String', 'Glib::String', 'Glib::String');
my $tree_view  = Gtk2::TreeView->new($tree_store);
$tree_view->signal_connect (button_release_event => \&button_release);
$tree_view->signal_connect ("row-activated"      => \&execute_code);
my $col = Gtk2::TreeViewColumn->new_with_attributes("Right click for demo", Gtk2::CellRendererText->new(), text => "0");
$tree_view->append_column($col);
$tree_view->set_headers_visible(0);

my $left_scroll = Gtk2::ScrolledWindow->new;
$left_scroll->set_shadow_type ('in');
$left_scroll->set_policy ('never', 'automatic');
$left_scroll->add($tree_view);

#$hbox->pack_start($left_scroll, FALSE, FALSE, 5);
$hbox->add1($left_scroll);

list_examples();
my $buffer = Gtk2::TextBuffer->new();
show_file($buffer, "welcome.txt");

my $textview = Gtk2::TextView->new_with_buffer($buffer);
$textview->set_wrap_mode("word");

my $right_scroll = Gtk2::ScrolledWindow->new;
$right_scroll->set_shadow_type ('in');
$right_scroll->set_policy ('automatic', 'automatic');
$right_scroll->add($textview);

$hbox->add2($right_scroll);
$hbox->set_position(200);


# pane for search results
my $sw = Gtk2::ScrolledWindow->new;
$sw->set_shadow_type ('in');
$sw->set_policy ('automatic', 'automatic');
$lower_pane->add2($sw);
$lower_pane->set_position(450);
show_search_results();


################ Add accelerators to the code
my @accels = (
	{ key => 'S', mod => 'control-mask', 
			func => sub {$search_entry->grab_focus(); $button_all->set_active(TRUE);} },
	{ key => 'F', mod => 'control-mask', 
			func => sub {$search_entry->grab_focus(); $button_buffer->set_active(TRUE); }},
	{ key => 'N', mod => 'control-mask', 
			func => \&search_again},
);
my $accel_group = Gtk2::AccelGroup->new;
use Gtk2::Gdk::Keysyms;
foreach my $a (@accels) {
	$accel_group->connect ($Gtk2::Gdk::Keysyms{$a->{key}}, $a->{mod},
	                       'visible', $a->{func});
}
$window->add_accel_group ($accel_group);
#################

$window->show_all();
Gtk2->main;

############################### END ################################

sub save_code {
	my $file_chooser = Gtk2::FileChooserDialog->new ('Save code',
				undef, 'save',
				'gtk-cancel' => 'cancel',
				'gtk-ok'     => 'ok');

	if ('ok' eq $file_chooser->run) {
		my $filename = $file_chooser->get_filename;
		if (-e $filename) {
			#print "filename $filename already exists\n";
		}
		if (open my $fh, ">", $filename) {
			print $fh $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
		}
	}
	$file_chooser->destroy;
}

sub execute_code {
	#if ($current_list eq "examples") {
		#my ($name, $type, $file) = _translate_tree_selection();
		#return if $type ne "file";
	#} else {
	#	my ($path, $col) = $tree_view->get_cursor(); 
	#	my @c = split /:/, $path->to_string;
	#	return if @c != 2;
	#}

	my ($fh, $temp_filename) = tempfile();
	print $fh $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
	close $fh;
	if (fork) {
		# parent
	} else {
		# child
		system($^X, $temp_filename);
		exit;
	}
	unlink $temp_filename;
	return;
}

sub add_entries {
	my ($tree, $parent, $entries) = @_;
	foreach my $entry (@$entries) {
		my $child = $tree_store->append($parent);
		$tree->set($child, 
			$ENTRY_NAME => $entry->{title}, 
			$ENTRY_TYPE => $entry->{type}, 
			$ENTRY_FILE => $entry->{name});
		if ($entry->{more}) {
			add_entries($tree, $child, $entry->{more});
		}
	}
}

sub list_examples {
	$tree_store->clear();
	$current_list = "examples";
	add_entries($tree_store, undef, \@entries);
}

sub list_widgets {
	$tree_store->clear();
	$current_list = "widgets";
	foreach my $widget (sort keys %widgets) {
		my $child = $tree_store->append(undef);
		$tree_store->set($child, 0, $widget);
		foreach my $file (sort keys %{$widgets{$widget}}) {
			my $grandchild = $tree_store->append($child);
			$tree_store->set($grandchild, 0, $file);
		}
	}
}
	
sub toggle_list {
	my ($widget) = @_;
	my $label = $widget->get_label;
	if ($label eq "List Widgets") {
		list_widgets();
		$widget->set_label("List Examples");
	} else {
		list_examples();
		$widget->set_label("List Widgets");
	}
}

sub _translate_tree_selection {
	my $model     = $tree_view->get_model();
	my $selection = $tree_view->get_selection();
	my $iter      = $selection->get_selected();
	return if not defined $iter;
	return $model->get($iter, $ENTRY_NAME, $ENTRY_TYPE, $ENTRY_FILE);
}

sub button_release {
	my ($self, $event) = @_;
	if ($current_list eq "examples") {
		select_example();
	} else { #"widgets"
		select_widget();
	}
	return;
}
sub select_widget {
	my ($path, $col) = $tree_view->get_cursor(); 
	my @c = split /:/, $path->to_string;
	if (@c == 1) {
		show_text($buffer, "Please select one of the files");	
	} elsif (@c == 2) {
		my $widget = (sort keys %widgets)[$c[0]];
	 	my $filename = (sort keys %{$widgets{$widget}})[$c[1]];
		show_file($buffer, $filename);
	} else {
		show_text($buffer, "Internal error, bad tree item: " . $path->to_string);
	}
}

sub select_example {
	my ($name, $type, $file) = _translate_tree_selection();
	return if not $name; # maybe some error message ?

	show_file($buffer, $file);
	return;
}

sub show_file {
	my ($buffer, $filename) = @_;
	my $code;
	$window->set_title("$title     '$filename'");
	if (open my $fh, $filename) {
		$code = join "", <$fh>;
		close $fh;
	} else {
		$code = "ERROR: Could not open $filename; $!";
	}
	show_text($buffer, $code);
}

sub show_text {
	my ($buffer, $text) = @_;
	$buffer->delete($buffer->get_start_iter, $buffer->get_end_iter);
	$buffer->insert($buffer->get_iter_at_line(0), $text);
}


sub collect_widgets {
	my ($entries) = @_;

	foreach my $entry (@$entries) {
		if ($entry->{type} eq "file") {
			analyze_file($entry->{name});
		}
		collect_widgets($entry->{more}) if $entry->{more};
	}
	return;
}

sub analyze_file {
	my ($file) = @_;
	open my $fh, $file or return;
	while (my $line = <$fh>) {
		if ($line =~ /(Gtk2::\w+(:?::\w+)*)/) {
			$widgets{$1}{$file}++;
		}
	}
}	

# check if we can read all the files listed in the entries.pl file
sub check_files {
	my ($entries) = @_;
	foreach my $entry (@$entries) {
		open my $fh, $entry->{name} or die "Could not open $entry->{name} $!";
		check_files($entry->{more}) if $entry->{more};
	}
}

sub search {
	my $search_text = $search_entry->get_text;
	if ($button_all->get_active()) {
		my %hits = _search($search_text, \@entries); 
		show_search_results(%hits);
	} else { # $button_buffer (this is the default if nothing is selected)
		#print "Search in text\n";
		search_buffer($search_text);
	}
}

sub search_again {
	my $search_text = $search_entry->get_text;
	return if not $search_text;
	search_buffer($search_text, "next");
}

sub _search {
	my ($text, $entries) = @_;

	my %resp;

	foreach my $entry (@$entries) {
		#$entry->{title}, 
		#$entry->{type}, 
		if (open my $fh, "<", $entry->{name}) {
			if (my @lines = grep /$text/, <$fh>) {
				chomp @lines;
				$resp{$entry->{name}} = \@lines;
			}
		}
		if ($entry->{more}) {
			%resp = (%resp, _search($text, $entry->{more}));
		}
	}
	return %resp;
}


#use constant STRING_COLUMN => 0;
sub show_search_results {
	my (%hits) = @_;
	my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String');

	foreach my $file (keys %hits) {
		foreach my $row (@{$hits{$file}}) {
			my $iter = $model->append;
			$model->set ($iter, 0 => $file, 1 => $row);
		}
	}

	my ($tree_view) = $sw->get_children();
	if ($tree_view) {
		$tree_view->set_model($model);
		return;
	}

	$tree_view = Gtk2::TreeView->new_with_model ($model);

	#$tree_view->set_reorderable (TRUE);
	#$model->signal_connect (rows_reordered => sub {print "rows reordered\n"});
	#$tree_view->get_selection->set_mode ('multiple');
	$tree_view->get_selection->signal_connect (changed => sub {
		# $_[0] is a GtkTreeSelection
		my ($tree_view) = $sw->get_children;
		my $model = $tree_view->get_model();
		my @sel    = $_[0]->get_selected_rows;
		my $iter   = $_[0]->get_selected();
		my ($file, $row) = $model->get($iter, 0, 1);
		show_file($buffer, $file);
		search_buffer($row);
	});
	
	$sw->add ($tree_view);


	my @titles = ("Filename", "Result Line");
	foreach my $i (0..@titles-1) {
		my $renderer = Gtk2::CellRendererText->new;
		my $column = Gtk2::TreeViewColumn->new_with_attributes ($titles[$i], 
							$renderer, 
							text => $i);
		$tree_view->append_column ($column);
	}
}

sub search_buffer {
	my ($text, $direction) = @_;

	#TextBuffer
	my $cont = $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
	my $start_index = 0;
	if ($direction) {
	#	$start_index = 20;
		my $mark = $buffer->get_selection_bound;
		#print "$mark\n";
		my $iter = $buffer->get_iter_at_mark($mark);
		#print $iter->get_offset, "\n";
		$start_index = $iter->get_offset;
	}
	
	
	my $start = index ($cont, $text, $start_index);
	return if $start == -1;
	#print "start: $start\n";
	my $start_iter = $buffer->get_iter_at_offset($start);
	my $end_iter   = $buffer->get_iter_at_offset($start+length($text));
	$buffer->select_range($start_iter, $end_iter);
	#$textview->scroll_to_iter($start_iter, 0.4, TRUE, 0.0, 0.0);
	my $mark = $buffer->create_mark("xxx", $start_iter, TRUE);
	$textview->scroll_to_mark($mark, 0.4, TRUE, 0.5, 0.5);
}


