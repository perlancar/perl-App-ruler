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
        background_pattern => {
            schema => ['str*', min_len=>1],
            default => '-',
            cmdline_aliases => {bg=>{}},
        },

        major_tick_every => {
            schema => ['int*', min=>1],
            default => 10,
            cmdline_aliases => {N=>{}},
        },
        major_tick_character => {
            schema => ['str', max_len=>1],
            default => '|',
            cmdline_aliases => {M=>{}},
        },

        minor_tick_every => {
            schema => ['int*', min=>1],
            default => 1,
            cmdline_aliases => {n=>{}},
        },
        minor_tick_character => {
            schema => ['str', max_len=>1],
            default => '.',
            cmdline_aliases => {m=>{}},
        },

        number_every => {
            schema => ['int*', min=>1],
            default => 10,
        },
        number_start => {
            schema => ['int*', min=>0],
            default => 10,
        },
        number_format => {
            schema => ['str*'],
            default => '%d',
            cmdline_aliases => {f=>{}},
        },
    },
};
sub ruler {
    my %args = @_;

    my $len = $args{length} // $term_width;

    my $bgpat = $args{background_pattern} // '-';
    my $mintickchar = $args{minor_tick_character} // '.';
    my $majtickchar = $args{major_tick_character} // '|';

    my $ruler = $bgpat x (int($len / length($bgpat)) + 1);

    if (length $mintickchar) {
        my $every = $args{minor_tick_every} // 1;
        for (1..$len) {
            if ($_ % $every == 0) {
                substr($ruler, $_-1, 1) = $mintickchar;
            }
        }
    }
    if (length $majtickchar) {
        my $every = $args{major_tick_every} // 10;
        for (1..$len) {
            if ($_ % $every == 0) {
                substr($ruler, $_-1, 1) = $majtickchar;
            }
        }
    }

    # draw numbers
    {
        no warnings; # e.g. when sprintf('', $_)
        my $numevery = $args{number_every} // 10;
        my $numstart = $args{number_start} // 10;
        my $fmt = $args{number_format} // '%d';
        for ($numstart..$len) {
            if ($_ % $numevery == 0) {
                my $num = sprintf($fmt, $_);
                substr($ruler, $_, length($num)) = $num;
            }
        }
    }

    # final clip
    $ruler = substr($ruler, 0, $len);
    $ruler .= "\n"
        unless $len == ($^O =~ /Win32/ ? $term_width-1 : $term_width);

    [200, "OK", $ruler];
}

1;
# ABSTRACT:

=head1 TIPS

To see background pattern, disable minor ticking by using C<< -m '' >>.

To disable numbering, set number format to an empty string: C<< -f '' >>.


=head1 SEE ALSO

L<hr> (L<App::hr>)

=cut
