package Parse::KyotoUniversityTextCorpus::Morpheme::MeCab;

use strict;
use warnings;
use v5.10;
use Class::Accessor::Lite (
  ro => [
    qw/base_form
       conjugation_form_type
       conjugation_type
       is_eos
       pos
       pronounciation
       reading
       surface/,
  ],
);
use Smart::Args;

sub new {
  my ($class, %args) = @_;

  my $method =
    delete $args{is_eos} ? 'new_eos_morpheme' : 'new_normal_morpheme';
  $class->$method(%args);
}

sub new_eos_morpheme {
  args
    my $class => 'ClassName';

  state $singleton = bless +{ is_eos => 1, surface => 'EOS' } => $class;
}

sub new_normal_morpheme {
  args
    my $class => 'ClassName',
    my $base_form => +{ isa => 'Str', optional => 1 },
    my $conjugation_form_type => +{ isa => 'Str', optional => 1 },
    my $conjugation_type => +{ isa => 'Str', optional => 1 },
    my $pos => 'ArrayRef[Str]',
    my $pronounciation => +{ isa => 'Str', optional => 1 },
    my $reading => +{ isa => 'Str', optional => 1 },
    my $surface => 'Str';

  bless +{
    base_form => $base_form,
    conjugation_form_type => $conjugation_form_type,
    conjugation_type => $conjugation_type,
    is_eos => 0,
    pos => $pos,
    pronounciation => $pronounciation,
    reading => $reading,
    surface => $surface,
  } => $class;
}

sub as_string {
  args
    my $self;

  return 'EOS' if $self->is_eos;

  my @pos = @{ $self->pos // [] };
  push @pos, '*' until @pos == 4;
  sprintf(
    "%s\t%s,%s,%s,%s,%s,%s,%s,%s,%s",
    $self->surface,
    @pos,
    map { $self->$_ // '*' } qw/conjugation_type
                                conjugation_form_type
                                base_form
                                reading
                                pronounciation/,
  );
}

sub has_base_form { defined $_[0]->base_form }

sub has_conjugation_type { defined $_[0]->conjugation_type }

sub has_conjugation_form_type { defined $_[0]->conjugation_form_type }

sub has_pronounciation { defined $_[0]->pronounciation }

sub has_reading { defined $_[0]->reading }

1;
