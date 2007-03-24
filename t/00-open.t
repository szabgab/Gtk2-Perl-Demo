#!/usr/bin/perl -w
use strict;

use Test::More;

BEGIN {
	eval {
		require X11::GUITest;
		import  X11::GUITest qw(:ALL);
	};
	if ($@) {
		plan skip_all => "X11::GUITest needed for these test";
	} else {
		plan tests => 3;
	}
}

ok(1);
StartApp("$^X gtk-perl-demo.pl");
my ($main_window) = WaitWindowViewable('GTK\+ Perl b', undef, 5);
ok($main_window) or die "Could not find main window\n";
diag $main_window;
diag GetWindowName $main_window;
my @children = GetChildWindows $main_window;
is(@children, 28, "28 children");
diag GetInputFocus();
SendKeys '{TAB 3}';
diag GetInputFocus();
#diag GetWindowName GetInputFocus(); # undef
sleep 2;
SendKeys '{ENT}';
#ClickWindow $main_window,,,
#my ($c) = FindWindowLike('Exit', $main_window, 5);
#diag $c;

#diag sprintf("%s %s",  $_, GetWindowName($_)) foreach @children


__END__

SendKeys("Hello, how are you?\n");
# Close Application (Alt-f, q).
SendKeys('%(f)q');
#if (WaitWindowViewable('Question', undef, 5)) {
if (WaitWindowViewable('', $GEditWinId, 5)) {
  # DoN't Save (Alt-n)
	SendKeys('%(n)');
}

