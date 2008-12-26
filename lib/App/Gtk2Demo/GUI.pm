package App::Gtk2Demo::GUI;
use strict;
use warnings;
 
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';
use Data::Dumper;
use File::Temp qw(tempfile);
use Time::HiRes qw(usleep);
use Getopt::Long qw(GetOptions);

my ($ENTRY_NAME, $ENTRY_TYPE, $ENTRY_FILE) = (0, 1, 2);
my ($SEARCH_FILENAME, $SEARCH_TEXT, $SEARCH_TITLE) = (0, 1, 2);

my $background;
my $entries;
sub set_entries {
    $entries = shift;
}

my $HISTORY_LIMIT = 20;
my @history;
my $history;

my $app_title = "GTK+ Perl binding Tutorial and code demos";
my ($widgets_store, $widgets_view, $widgets_scroll);
my ($files_store, $files_view, $files_scroll);
my $window;
my $widgets;

{
    my %widget;
    sub get_widget {
        my ($name) = @_;
        return $widget{$name};
    }
    sub set_widget {
        my ($name, $value) = @_;
        $widget{$name} = $value;
        return;
    }
}

sub build_gui {
    ($widgets) = @_;
    eval "use Gtk2::SourceView;";
    my $sourceview = not $@;
    if ($@) {
        warn "It would be nicer if you could install Gtk2::SourceView\n";
    }

    ##### Main window
    $window = Gtk2::Window->new;
    $window->set_title($app_title);
    $window->signal_connect (destroy => sub { Gtk2->main_quit; });
    my $HEIGHT = 700;
    my $WIDTH = 600;
    $window->set_default_size($WIDTH, $HEIGHT);
    
    ###### Main box
    my $main_vbox = Gtk2::VBox->new();
    $window->add($main_vbox);
    my $menu_row = _create_menu_row();
    $main_vbox->pack_start($menu_row, FALSE, FALSE, 5);
   
    my $history_row = _create_history_row();
    $main_vbox->pack_start($history_row, FALSE, FALSE, 5);
   
    ################# Add lower panes
    my $lower_pane = Gtk2::VPaned->new();
    $main_vbox->pack_start($lower_pane, TRUE, TRUE, 5);
    
    my $hbox = _create_left_pane();
    $lower_pane->add1($hbox);
    list_examples($files_store, $files_store, undef, $entries);
    list_widgets($widgets);


    my ($textview, $buffer);
    if ($sourceview) {
        ($textview, $buffer) = sourceview();
    } else {
        $buffer = Gtk2::TextBuffer->new();
        $textview = Gtk2::TextView->new_with_buffer($buffer);
    }
    set_widget(buffer   => $buffer);
    set_widget(textview => $textview);
    show_file("welcome.txt", "Welcome");
    
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
    $lower_pane->set_position($HEIGHT-300);
    set_widget(sw => $sw);
    
    my $results_view = _add_results_box();
    $sw->add($results_view);
    
    _add_accelerators($window);
    $window->show_all();
    Gtk2->main;
}

sub _add_results_box {
    my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String', 'Glib::String');
    my $results_view = Gtk2::TreeView->new_with_model ($model);

    $results_view->signal_connect ('cursor-changed' => sub {
        my ($some_tree_view) = $_[0]; #Gtk2::TreeView
        my $model  = $some_tree_view->get_model();
        my $tree_selection  = $some_tree_view->get_selection();
        my $iter   = $tree_selection->get_selected();
        my ($file, $text, $title) = $model->get($iter, $SEARCH_FILENAME, $SEARCH_TEXT, $SEARCH_TITLE); 
        show_file($file, $title);
        search_buffer($text);
    });
    

    my @titles = ("Filename", "_Result Line");
    foreach my $i (0..@titles-1) {
        my $renderer = Gtk2::CellRendererText->new;
        my $column = Gtk2::TreeViewColumn->new_with_attributes ($titles[$i], 
                            $renderer, 
                            text => $i);
        $results_view->append_column ($column);
    }
    return $results_view;
}

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
    get_widget('history_opt')->set_menu($history_menu);
}


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
        my $buffer = get_widget('buffer');
        if (open my $fh, ">", $filename) {
            print {$fh} $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
        }
    }
    $file_chooser->destroy;
}

sub execute_code {
    my ($fh, $temp_filename) = tempfile();
    my $buffer = get_widget('buffer');
    print {$fh} $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
    $fh->flush;
    close $fh;

    usleep(1000); # to make sure the file was fully flushed by the OS 
                  # it seems when we started to use fork, and later the background execution mode
                  # ocassionally the file was not yet created before the code reached system()
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
    my ($widgets) = @_;
    foreach my $widget (sort keys %$widgets) {
        my $child = $widgets_store->append(undef);
        $widgets_store->set($child, 0, $widget);
        foreach my $file (sort keys %{$widgets->{$widget}}) {
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
    if (get_widget('notebook')->get_current_page()) {
        select_widget(); # 1
    } else {
        select_example(); # 0
    }
    return;
}


sub build_podview {
    my ($module) = @_;
    eval "use Gtk2::Ex::PodViewer";
    return if $@;
    return;
    print "display\n";
    my $viewer = Gtk2::Ex::PodViewer->new;
    print "V: $viewer\n";
    #$viewer->load(’/path/to/file.pod’); 
    $viewer->load($module);
    print "loaded\n";
    $viewer->show;
    my $window = Gtk2::Window->new;
    $window->add($viewer);
    $window->show;
    print "showed\n";

    $window->signal_connect (destroy => sub { Gtk2->main_quit; });

    Gtk2->main;
}

sub select_widget {
    my ($path, $col) = $widgets_view->get_cursor(); 
    my @c = split /:/, $path->to_string;
    my $widget = (sort keys %$widgets)[$c[0]];
    if (@c == 1) {
        show_text("Please select one of the files to examples for $widget");
    } elsif (@c == 2) {
        my $filename = (sort keys %{$widgets->{$widget}})[$c[1]];
        show_file($filename, $widgets->{$widget}{$filename});
    } else {
        show_text("Internal error, bad tree item: " . $path->to_string);
    }
}

sub select_example {
    my ($name, $type, $file) = _translate_tree_selection();
    return if not $name; # maybe some error message ?

    show_file($file, $name);
    return;
}

sub show_file {
    my ($filename, $title) = @_;
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
    show_text($code);
}

sub show_text {
    my ($text) = @_;
    my $buffer = get_widget('buffer'); 
    $buffer->delete($buffer->get_start_iter, $buffer->get_end_iter);
    $buffer->insert($buffer->get_iter_at_line(0), $text);
}

sub search {
    my $search_text = get_widget('search_entry')->get_text;
    if (get_widget('button_all')->get_active()) {
        my %hits = _search($search_text, $entries); 
        show_search_results(%hits);

    } else { # button_buffer (this is the default if nothing is selected)
        #print "Search in text\n";
        search_buffer($search_text);
    }
}

sub search_again {
    my $search_text = get_widget('search_entry')->get_text;
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
    return if not %hits;
#print Dumper \%hits;
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

    my ($results_view) = get_widget('sw')->get_children();
    if ($results_view) {
        #print "$results_view\n";
        $results_view->set_model($model);
        $results_view->set_cursor(Gtk2::TreePath->new(0));
    }
    return;
}

sub search_buffer {
    my ($text, $direction) = @_;

    #TextBuffer
    my $buffer = get_widget('buffer');
    my $cont = $buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, 0);
    my $start_index = 0;
    if ($direction) {
    #   $start_index = 20;
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
    my $textview = get_widget('textview');
    #$textview->scroll_to_iter($start_iter, 0.4, TRUE, 0.0, 0.0);
    my $mark = $buffer->create_mark("xxx", $start_iter, TRUE);
    $textview->scroll_to_mark($mark, 0.4, TRUE, 0.5, 0.5);
}

sub show_history {
    #my $menu = $history_opt->get_menu or return;
    #my $item = $menu->get_active or return;
    #print Dumper $history;
    return if not $history;
    show_file($history->{filename}, $history->{title});
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
    #   $sb->insert($sb->get_end_iter(), $_);
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

    return if not get_widget('notebook')->get_current_page();
    #print "clicked\n";
    if (3 eq $event->button) {
        print "right clicked\n";
        my ($path, $col) = $widgets_view->get_cursor(); 
        my @c = split /:/, $path->to_string;
        my $widget = (sort keys %$widgets)[$c[0]];
        print "display pod for $widget\n";
        build_podview($widget);
        print "right click done\n";
    }
}

sub _create_search_button {
    my $button = Gtk2::Button->new_from_stock('gtk-find');
    $button->signal_connect(clicked=> \&search);
    $button->can_default(TRUE);
    return $button;
}

sub _add_radio_buttons {
    my $menu_row = shift;

    my $radio_buttons = Gtk2::HBox->new();
    $menu_row->pack_start($radio_buttons, FALSE, FALSE, 0);
    
    my $button_all = Gtk2::RadioButton->new(undef, "All files");
    $radio_buttons->pack_start($button_all, TRUE, TRUE, 0);
    $button_all->set_active(TRUE);
    $button_all->show;
    my @group = $button_all->get_group;
    set_widget(button_all => $button_all);
    
    my $button_buffer = Gtk2::RadioButton->new_with_label(@group, "Current buffer");
    $radio_buttons->pack_start($button_buffer, TRUE, TRUE, 0);
    $button_buffer->show;
    set_widget(button_buffer => $button_buffer);
}

sub _create_menu_row {
    my $menu_row = Gtk2::HBox->new();
    
    my $execute_button = Gtk2::Button->new_from_stock('gtk-execute');
    $execute_button->signal_connect(clicked=> \&execute_code);
    $menu_row->pack_start($execute_button, FALSE, FALSE, 5);
    
    my $save_button = Gtk2::Button->new_from_stock('gtk-save');
    $save_button->signal_connect(clicked=> \&save_code);
    $menu_row->pack_start($save_button, FALSE, FALSE, 5);
    
    my $search_entry = Gtk2::Entry->new;
    $search_entry->set_activates_default (TRUE);
    $menu_row->pack_start($search_entry, FALSE, FALSE, 5);
    set_widget(search_entry => $search_entry);
   
    _add_radio_buttons($menu_row);
    
    my $search_button = _create_search_button();
    $menu_row->pack_start($search_button, FALSE, FALSE, 5);
    $window->set_default($search_button);
    set_widget(search_button => $search_button);
   
    
    my $exit_button = Gtk2::Button->new_from_stock('gtk-quit');
    $exit_button->signal_connect(clicked=> sub { Gtk2->main_quit; });
    $menu_row->pack_end($exit_button, FALSE, FALSE, 5);
    return $menu_row;
}    

sub _add_accelerators {
    my $window = shift;
    my @accels = (
        { key => 'S', mod => 'control-mask', 
                func => sub {get_widget('search_entry')->grab_focus(); get_widget('button_all')->set_active(TRUE);} },
        { key => 'F', mod => 'control-mask', 
                func => sub {get_widget('search_entry')->grab_focus(); get_widget('button_buffer')->set_active(TRUE); }},
        { key => 'N', mod => 'control-mask', 
                func => \&search_again},
    );
    my $accel_group = Gtk2::AccelGroup->new;
    use Gtk2::Gdk::Keysyms;
    foreach my $a (@accels) {
        $accel_group->connect ($Gtk2::Gdk::Keysyms{$a->{key}}, $a->{mod},
                               'visible', $a->{func});
    }
    $window->add_accel_group($accel_group);
}

sub _create_history_row {
    my $history_row = Gtk2::HBox->new();
    
    my $history_label = Gtk2::Label->new("History");
    $history_row->pack_start($history_label, FALSE, FALSE, 5);
    
    my $history_opt = Gtk2::OptionMenu->new;
    #$history_opt->set_history (1);
    $history_row->pack_start($history_opt, FALSE, FALSE, 5);
    set_widget(history_opt => $history_opt);
    
    my $history_button = Gtk2::Button->new_from_stock('gtk-jump-to');
    $history_button->signal_connect(clicked=> \&show_history);
    $history_row->pack_start($history_button, FALSE, FALSE, 5);
    return $history_row;
} 

###### file or Widget listing
sub _create_left_pane {
    my $hbox = Gtk2::HPaned->new();
    ($files_store, $files_view, $files_scroll) = create_tree();
    ($widgets_store, $widgets_view, $widgets_scroll) = create_tree();
    my $notebook = Gtk2::Notebook->new();
    $hbox->add($notebook);
    $notebook->append_page($files_scroll, "Files");
    $notebook->append_page($widgets_scroll, "Widgets");
    set_widget(notebook => $notebook);

    return $hbox; 
}

  
1;



