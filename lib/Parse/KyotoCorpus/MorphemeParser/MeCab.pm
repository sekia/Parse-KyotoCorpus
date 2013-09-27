package Parse::KyotoCorpus::MorphemeParser::MeCab;

use v5.14;
use Parse::KyotoCorpus::Morpheme::MeCab;
use Smart::Args;

sub new { bless \my $dummy => $_[0] }

sub parse {
  args_pos
    my $self,
    my $line => 'Str';

  if ($line eq 'EOS') {
    return Parse::KyotoCorpus::Morpheme::MeCab->new(is_eos => 1);
  }
  my ($surface, $feature) = split /\t/, $line, 2;
  my @feature = map { $_ eq '*' ? undef : $_ } split /,/, $feature;
  my @pos = splice @feature, 0, 4;
  pop @pos until defined $pos[-1];
  my (
    $conjugation_type,
    $conjugation_form_type,
    $base_form,
    $reading,
    $pronounciation,
  ) = @feature;
  Parse::KyotoCorpus::Morpheme::MeCab->new(
    +(defined $base_form ? (base_form => $base_form) : ()),
    +(defined $conjugation_form_type
        ? (conjugation_form_type => $conjugation_form_type) : ()),
    +(defined $conjugation_type
        ? (conjugation_type => $conjugation_type) : ()),
    +(defined $pronounciation ? (pronounciation => $pronounciation) : ()),
    +(defined $reading ? (reading => $reading) : ()),
    pos => \@pos,
    surface => $surface,
  );
}

1;

__DATA__

=head1 NAME

Parse::KyotoCorpus::MorphemeParser::MeCab;

=head1 DESCRIPTION

This class parses MeCab's default node format.

Note that MeCab's output format is configurable and this class does not care about it.

=cut