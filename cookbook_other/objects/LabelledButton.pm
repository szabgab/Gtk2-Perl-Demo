package LabelledButton;

use Glib::Object::Subclass
  Gtk2::Button::,
    signals => { map => \&on_map, },
      ;
      
      
      sub on_map {
        my $self = shift;
	  $self->set('label'=>'Hello World');
	    $self->signal_chain_from_overridden;
	    }
	    1;