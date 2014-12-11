package App::ruler;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moo;
with 'Term::App::Role::Attrs';

has width => (is=>'rw');
has major_tick => (is=>'rw', default=>5);
has major_tick_character => (is=>'rw', default=>'');
has minor_tick => (is=>'rw', default=>1);
has minor_tick_character => (is=>'rw', default=>1);

sub gen_ruler {
}

1;
# ABSTRACT: Print ruler on the terminal
