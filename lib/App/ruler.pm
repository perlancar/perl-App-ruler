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

sub _colored {
    require Term::ANSIColor;
    Term::ANSIColor::colored(@_);
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
        background_color => {
            schema => ['str*'],
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
        major_tick_color => {
            schema => ['str*'],
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
        minor_tick_color => {
            schema => ['str*'],
        },

        number_every => {
            schema => ['int*', min=>0], # 0 means do not draw
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
        number_color => {
            schema => ['str*'],
        },
    },
    examples => [
        {
            summary => 'Default ruler (dash + number every 10 characters)',
            args => {},
        },
        {
            summary => 'White ruler with red marks and numbers',
            args => {
                background_color => "black on_white",
                minor_tick_character => '',
                major_tick_color => "red on_white",
                number_color => "bold red on_white",
            },
        },
    ],
};
sub ruler {
    my %args = @_;

    my $ruler_len = $args{length} // $term_width;
    my $use_color;

    # draw background
    my $bgpat = $args{background_pattern} // '-';
    my $ruler = $bgpat x (int($ruler_len / length($bgpat)) + 1);
    if ($args{background_color}) {
        $use_color++;
        $ruler = _colored($ruler, $args{background_color});
    }

    # draw minor ticks
    my $mintickchar = $args{minor_tick_character} // '.';
    if ($args{minor_tick_color} && length($mintickchar)) {
        $use_color++;
        $mintickchar = _colored($mintickchar, $args{minor_tick_color});
    }
    if (length $mintickchar) {
        my $every = $args{minor_tick_every} // 1;
        for (1..$ruler_len) {
            if ($_ % $every == 0) {
                if ($use_color) {
                    require Text::ANSI::NonWideUtil;
                    $ruler = Text::ANSI::NonWideUtil::ta_substr($ruler, $_-1, 1, $mintickchar);
                } else {
                    substr($ruler, $_-1, 1) = $mintickchar;
                }
            }
        }
    }

    # draw major ticks
    my $majtickchar = $args{major_tick_character} // '|';
    if ($args{major_tick_color} && length($majtickchar)) {
        $use_color++;
        $majtickchar = _colored($majtickchar, $args{major_tick_color});
    }
    if (length $majtickchar) {
        my $every = $args{major_tick_every} // 10;
        for (1..$ruler_len) {
            if ($_ % $every == 0) {
                if ($use_color) {
                    require Text::ANSI::NonWideUtil;
                    $ruler = Text::ANSI::NonWideUtil::ta_substr($ruler, $_-1, 1, $majtickchar);
                } else {
                    substr($ruler, $_-1, 1) = $majtickchar;
                }
            }
        }
    }

    # draw numbers
    {
        no warnings; # e.g. when sprintf('', $_)
        my $numevery = $args{number_every} // 10;
        last unless $numevery > 0;
        my $numstart = $args{number_start} // 10;
        my $fmt = $args{number_format} // '%d';
        $use_color++ if $args{number_color};
        for ($numstart..$ruler_len) {
            if ($_ % $numevery == 0) {
                my $num = sprintf($fmt, $_);
                my $num_len;
                if ($args{number_color}) {
                    $num = _colored($num, $args{number_color});
                    require Text::ANSI::NonWideUtil;
                    $num_len = Text::ANSI::NonWideUtil::ta_length($num);
                } else {
                    $num_len = length($num);
                }
                if ($use_color) {
                    require Text::ANSI::NonWideUtil;
                    $ruler = Text::ANSI::NonWideUtil::ta_substr($ruler, $_, $num_len, $num);
                } else {
                    substr($ruler, $_, $num_len) = $num;
                }
            }
        }
    }

    # final clip
    if ($use_color) {
        require Text::ANSI::NonWideUtil;
        $ruler = Text::ANSI::NonWideUtil::ta_substr($ruler, 0, $ruler_len);
    } else {
        $ruler = substr($ruler, 0, $ruler_len);
    }
    $ruler .= "\n"
        unless $ruler_len == ($^O =~ /Win32/ ? $term_width-1 : $term_width);

    [200, "OK", $ruler];
}

1;
# ABSTRACT:

=head1 TIPS

To see background pattern, disable minor ticking by using C<< -m '' >>.

To disable numbering, set number format to an empty string: C<< -f '' >> or C<<
--number-every 0 >>.


=head1 SEE ALSO

L<hr> (L<App::hr>)

=cut
