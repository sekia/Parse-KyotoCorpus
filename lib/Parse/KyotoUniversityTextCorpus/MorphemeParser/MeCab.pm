package Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab;

use v5.10;
use Parse::KyotoUniversityTextCorpus::Morpheme::MeCab;
use Smart::Args;

sub new { bless \my $dummy => $_[0] }

sub parse {
  args_pos
    my $self,
    my $line => 'Str';

  if ($line eq 'EOS') {
    return Parse::KyotoUniversityTextCorpus::Morpheme::MeCab->new(is_eos => 1);
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
  Parse::KyotoUniversityTextCorpus::Morpheme::MeCab->new(
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

Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab;

=head1 DESCRIPTION

This class parses MeCab's default morpheme format.

Note that although MeCab's output format and using dictionary is configurable, this class can only parse default output format with features from IPA dictionary.

=cut
