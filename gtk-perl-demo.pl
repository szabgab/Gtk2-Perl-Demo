#!/usr/bin/perl -w
use strict;
use warnings;
 
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';
use Data::Dumper;
use File::Temp qw(tempfile);
use Time::HiRes qw(usleep);
use Getopt::Long qw(GetOptions);

eval "use Gtk2::SourceView;";
my $sourceview = not $@;
my $background;

GetOptions(
	"background|b" => \$background,
	"sourceview|s" => \$sourceview,
	);

our $VERSION = '0.04';
my ($ENTRY_NAME, $ENTRY_TYPE, $ENTRY_FILE) = (0, 1, 2);
my ($SEARCH_FILENAME, $SEARCH_TEXT, $SEARCH_TITLE) = (0, 1, 2);

my @entries = do "entries.pl"; 
if (@ARGV and $ARGV[0] eq "check") {
	check_files(\@entries);
	print "All the files are readable\n";
	exit;
}
my $HISTORY_LIMIT = 20;
my @history;
my $history;

my $app_title = "GTK+ Perl binding Tutorial and code demos";
my %files;
my %widgets;
collect_widgets(\@entries);
 
##### Main window
my $window = Gtk2::Window->new;
$window->set_title($app_title);
$window->signal_connect (destroy => sub { Gtk2->main_quit; });
$window->set_default_size(900, 650);

###### Main box
my $main_vbox = Gtk2::VBox->new();
$window->add($main_vbox);


##### Menu row
my $menu_row = Gtk2::HBox->new();
$main_vbox->pack_start($menu_row, FALSE, FALSE, 5);

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


####################### History row
my $history_row = Gtk2::HBox->new();
$main_vbox->pack_start($history_row, FALSE, FALSE, 5);

my $history_label = Gtk2::Label->new("History");
$history_row->pack_start($history_label, FALSE, FALSE, 5);

my $history_opt = Gtk2::OptionMenu->new;

sub list_history {
	my $history_menu = Gtk2::Menu->new;
	foreach my $h (reverse @history) {
		#print "Add: $h->{title}\n";
		my $item = Gtk2::MenuItem->new ($h->{title}); # filename
		$item->signal_connect (activate => sub {
				$history = $_[1];
			}, $h);
		$item->show;
		$history_menu->append ($item);
	}
	$history_opt->set_menu ($history_menu);
}
#$history_opt->set_history (1);
$history_row->pack_start($history_opt, FALSE, FALSE, 5);

my $history_button = Gtk2::Button->new_from_stock('gtk-jump-to');
$history_button->signal_connect(clicked=> \&show_history);
$history_row->pack_start($history_button, FALSE, FALSE, 5);


################# Add lower panes
my $lower_pane = Gtk2::VPaned->new();
$main_vbox->pack_start($lower_pane, TRUE, TRUE, 5);


###### Left pane, file or Widget listing
my $hbox = Gtk2::HPaned->new();
$lower_pane->add1($hbox);

my ($files_store, $files_view, $files_scroll) = create_tree();
my ($widgets_store, $widgets_view, $widgets_scroll) = create_tree();
sub create_tree {
	my $tree_store = Gtk2::TreeStore->new('Glib::String', 'Glib::String', 'Glib::String');
	my $tree_view  = Gtk2::TreeView->new($tree_store);
	$tree_view->signal_connect (button_release_event => \&button_release);
	$tree_view->signal_connect ("row-activated"      => \&execute_code);
	$tree_view->signal_connect ("button_press_event" => \&right_click);
	my $col = Gtk2::TreeViewColumn->new_with_attributes("Right click for demo", Gtk2::CellRendererText->new(), text => "0");
	$tree_view->append_column($col);
	$tree_view->set_headers_visible(0);

	my $left_scroll = Gtk2::ScrolledWindow->new;
	$left_scroll->set_shadow_type ('in');
	$left_scroll->set_policy ('never', 'automatic');
	$left_scroll->add($tree_view);
	return ($tree_store, $tree_view, $left_scroll);
}


my $notebook = Gtk2::Notebook->new();
$hbox->add($notebook);
$notebook->append_page($files_scroll, "Files");
$notebook->append_page($widgets_scroll, "Widgets");

list_examples($files_store, $files_store, undef, \@entries);
list_widgets();

my ($buffer, $textview);

if ($sourceview) {
	($textview, $buffer) = sourceview();
} else {
	$buffer = Gtk2::TextBuffer->new();
	$textview = Gtk2::TextView->new_with_buffer($buffer);
}


show_file($buffer, "welcome.txt", "Welcome");

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
	my ($fh, $temp_filename) = tempfile();
	print $fh $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
	$fh->flush;
	close $fh;

	usleep(1000); # to make sure the file was fully flushed by the OS 
	              # it seems when we started to use fork, and later the background execution
	       	      # ocassionally the file was not yet created by them the code reached system()
	              # very strange
	if ($^O =~ /win/i) {
		system("start $^X $temp_filename");
	} else {
		system("$^X $temp_filename" . ($background ? " &" : ""));
	}
	unlink $temp_filename;
	return;
}

sub list_examples {
	my ($tree, $tree_store, $parent, $entries) = @_;
	foreach my $entry (@$entries) {
		my $child = $tree_store->append($parent);
		$tree->set($child, 
			$ENTRY_NAME => $entry->{title}, 
			$ENTRY_TYPE => $entry->{type}, 
			$ENTRY_FILE => $entry->{name});
		if ($entry->{more}) {
			list_examples($tree, $tree_store, $child, $entry->{more});
		}
	}
}


sub list_widgets {
	foreach my $widget (sort keys %widgets) {
		my $child = $widgets_store->append(undef);
		$widgets_store->set($child, 0, $widget);
		foreach my $file (sort keys %{$widgets{$widget}}) {
			my $grandchild = $widgets_store->append($child);
			$widgets_store->set($grandchild, 0, $file);
		}
	}
}
	
sub _translate_tree_selection {
	my $model     = $files_view->get_model();
	my $selection = $files_view->get_selection();
	my $iter      = $selection->get_selected();
	return if not defined $iter;
	return $model->get($iter, $ENTRY_NAME, $ENTRY_TYPE, $ENTRY_FILE);
}

sub button_release {
	my ($self, $event) = @_;
	if ($notebook->get_current_page()) {
		select_widget(); # 1
	} else {
		select_example(); # 0
	}
	return;
}


sub build_podview {
	my ($module) = @_;
	eval "use Gtk2::PodViewer";
	my $viewer = Gtk2::PodViewer->new;

	#$viewer->load(’/path/to/file.pod’); 
	$viewer->load($module);       
	$viewer->show;                  
	my $window = Gtk2::Window->new;
	$window->add($viewer);
	$window->show;

	$window->signal_connect (destroy => sub { Gtk2->main_quit; });

	Gtk2->main;
}

sub select_widget {
	my ($path, $col) = $widgets_view->get_cursor(); 
	my @c = split /:/, $path->to_string;
	my $widget = (sort keys %widgets)[$c[0]];
	if (@c == 1) {
		show_text($buffer, "Please select one of the files to examples for $widget");
	} elsif (@c == 2) {
	 	my $filename = (sort keys %{$widgets{$widget}})[$c[1]];
		show_file($buffer, $filename, $widgets{$widget}{$filename});
	} else {
		show_text($buffer, "Internal error, bad tree item: " . $path->to_string);
	}
}

sub select_example {
	my ($name, $type, $file) = _translate_tree_selection();
	return if not $name; # maybe some error message ?

	show_file($buffer, $file, $name);
	return;
}

sub show_file {
	my ($buffer, $filename, $title) = @_;
	if ($filename =~ /.pl$/) {
		push @history, {
			filename => $filename,
			title    => $title,
		};
		shift @history if @history > $HISTORY_LIMIT;
		#print map {$_->{filename} . "\n"} @history;
	}
	list_history(); 
	my $code;
	$title ||= "NA";
	$window->set_title("$app_title     $title: '$filename'");
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
			analyze_file($entry->{name}, $entry->{title});
		}
		collect_widgets($entry->{more}) if $entry->{more};
	}
	return;
}

sub analyze_file {
	my ($file, $title) = @_;
	open my $fh, $file or return;
	while (my $line = <$fh>) {
		if ($line =~ /(Gtk2::\w+(:?::\w+)*)/) {
			$widgets{$1}{$file} = $title;
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
		#$entry->{type}, 
		if (open my $fh, "<", $entry->{name}) {
			if (my @lines = grep /$text/, <$fh>) {
				chomp @lines;
				$resp{$entry->{name}}{lines} = \@lines;
				$resp{$entry->{name}}{title} = $entry->{title};
			}
		}
		if ($entry->{more}) {
			%resp = (%resp, _search($text, $entry->{more}));
		}
	}
	return %resp;
}

sub show_search_results {
	my (%hits) = @_;
	my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String', 'Glib::String');

	foreach my $file (keys %hits) {
		foreach my $row (@{$hits{$file}{lines}}) {
			my $iter = $model->append;
			$model->set ($iter, 
				$SEARCH_FILENAME => $file, 
				$SEARCH_TEXT     => $row, 
				$SEARCH_TITLE    => $hits{$file}{title}
			);
		}
	}

	my ($results_view) = $sw->get_children();
	if ($results_view) {
		$results_view->set_model($model);
		return;
	}

	$results_view = Gtk2::TreeView->new_with_model ($model);

	#$results_view->set_reorderable (TRUE);
	#$model->signal_connect (rows_reordered => sub {print "rows reordered\n"});
	#$results_view->get_selection->set_mode ('multiple');
	$results_view->get_selection->signal_connect (changed => sub {
		# $_[0] is a GtkTreeSelection
		my ($some_tree_view) = $sw->get_children;
		my $model  = $some_tree_view->get_model();
		my @sel    = $_[0]->get_selected_rows;
		my $iter   = $_[0]->get_selected();
		my ($file, $text, $title) = $model->get($iter, $SEARCH_FILENAME, $SEARCH_TEXT, $SEARCH_TITLE); 
		show_file($buffer, $file, $title);
		search_buffer($text);
	});
	
	$sw->add ($results_view);


	my @titles = ("Filename", "_Result Line");
	foreach my $i (0..@titles-1) {
		my $renderer = Gtk2::CellRendererText->new;
		my $column = Gtk2::TreeViewColumn->new_with_attributes ($titles[$i], 
							$renderer, 
							text => $i);
		$results_view->append_column ($column);
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

sub show_history {
	#my $menu = $history_opt->get_menu or return;
	#my $item = $menu->get_active or return;
	#print Dumper $history;
	return if not $history;
	show_file($buffer, $history->{filename}, $history->{title});
}


sub sourceview {
	my $lm = Gtk2::SourceView::LanguagesManager->new;
	my $lang = $lm->get_language_from_mime_type("application/x-perl");
	my $sb;
	if ($lang) {
		$sb = Gtk2::SourceView::Buffer->new_with_language($lang);
		$sb->set_highlight(1);
	} else {
		$sb = Gtk2::SourceView::Buffer->new(undef);
		$sb->set_highlight(0);
	}

	# loading a file should be atomically undoable.
	#$sb->begin_not_undoable_action();
	#open my $infile, $0 or die "Unable to open program.pl";
	#while (<$infile>) {
	#	$sb->insert($sb->get_end_iter(), $_);
	#}
	#$sb->end_not_undoable_action();

	# Gtk2::SourceView::Buffer inherits from Gtk2::TextBuffer.
	#$sb->set_modified(0);
	#$sb->place_cursor($sb->get_start_iter());
	my $view = Gtk2::SourceView::View->new_with_buffer($sb);

	return ($view, $sb);
}

sub right_click {
	my ($check, $event) = @_;

	return if not $notebook->get_current_page();
	#print "click pressed\n";
	if (3 eq $event->button) {
		my ($path, $col) = $widgets_view->get_cursor(); 
		my @c = split /:/, $path->to_string;
		my $widget = (sort keys %widgets)[$c[0]];
		build_podview($widget);
		#print "right click pressed\n";
	}
}



