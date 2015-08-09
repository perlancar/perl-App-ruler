package App::ruler;

# DATE
# VERSION

use feature 'say';
use strict 'subs', 'vars';
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       ruler
               );

our %SPEC;

my $term_width;
if (eval { require Term::Size; 1 }) {
    ($term_width, undef) = Term::Size::chars();
} else {
    $term_width = 80;
}

$SPEC{ruler} = {
    v => 1.1,
    summary => 'Print horizontal ruler on the terminal',
    args_rels => {
        'choose_one&' => [
            #[qw/color random_color/],
        ],
    },
    args => {
        length => {
            schema => ['int*', min=>0],
            cmdline_aliases => {l=>{}},
        },
        background_character => {
            schema => ['str*', len=>1],
            default => '-',
        },

        major_tick_every => {
            schema => ['int*', min=>1],
            default => 10,
        },
        major_tick_character => {
            schema => ['str', len=>1],
            default => '|',
        },

        minor_tick_every => {
            schema => ['int*', min=>1],
            default => 1,
        },
        minor_tick_character => {
            schema => ['str', len=>1],
            default => '.',
        },

        number_every => {
            schema => ['int*', min=>1],
            default => 10,
        },
        number_start => {
            schema => ['int*', min=>0],
            default => 10,
        },
    },
};
sub ruler {
    my %args = @_;

    my $len = $args{length} // $term_width;

    # XXX schema
    my $bgchar = $args{background_character} // '-';
    return [400, "Background character is not a single character"]
        unless length($bgchar) == 1;
    my $mintickchar = exists($args{minor_tick_character}) ?
        $args{minor_tick_character} : '.';
    return [400, "Minor tick character is not a single character"]
        if defined($mintickchar) && length($mintickchar) != 1;
    my $majtickchar = exists($args{major_tick_character}) ?
        $args{major_tick_character} : '|';
    return [400, "Major tick character is not a single character"]
        if defined($majtickchar) && length($majtickchar) != 1;

    my $ruler = $bgchar x $len;

    if (defined $mintickchar) {
        my $every = $args{minor_tick_every} // 1;
        for (1..$len) {
            if ($_ % $every == 0) {
                substr($ruler, $_-1, 1) = $mintickchar;
            }
        }
    }
    if (defined $majtickchar) {
        my $every = $args{major_tick_every} // 10;
        for (1..$len) {
            if ($_ % $every == 0) {
                substr($ruler, $_-1, 1) = $majtickchar;
            }
        }
    }

    # draw numbers
    {
        my $numevery = $args{number_every} // 10;
        my $numstart = $args{number_start} // 10;
        for ($numstart..$len) {
            if ($_ % $numevery == 0) {
                my $num = $_;
                substr($ruler, $_, length($num)) = $num;
            }
        }
    }

    # clip again
    $ruler = substr($ruler, 0, $len) if length($ruler) > $len;

    [200, "OK", $ruler];
}

1;
# ABSTRACT:

=head1 SEE ALSO

L<hr> (L<App::hr>)

=cut
