package Parse::KyotoCorpus;

# ABSTRACT: Parse Kyoto Corpus-formatted text.

use v5.14;
use Carp qw//;
use List::MoreUtils qw/none/;
use Parse::KyotoCorpus::Chunk;
use Smart::Args;

our $VERSION = '0.01';

sub new {
  args
    my $class => 'ClassName',
    my $morpheme_parser => 'Parse::KyotoCorpus::MorphemeParser';

  bless +{ morpheme_parser => $morpheme_parser } => $class;
}

sub do_parse {
  args_pos
    my $self,
    my $fh => 'FileHandle';

  my %dependency_ids;
  my %parsed_chunks;
  my $current_chunk = Parse::KyotoCorpus::Chunk->new(id => -1);
  while (<$fh>) {
    chomp;
    next if /^#/;

    if (/^\*/) {  # Chunk header.
      $parsed_chunks{$current_chunk->id} = $current_chunk;
      my (undef, $chunk_id, $dependency_id) = split /\s+/;
      $current_chunk = Parse::KyotoCorpus::Chunk->new(id => $chunk_id);
      ($dependency_id, my $dependency_type) =
        $dependency_id =~ /^(-?\d+)([ADP])$/;
      $dependency_ids{$chunk_id} = [$dependency_id => $dependency_type];
    } else {  # Morpheme.
      my $morpheme = $self->morpheme_parser->parse($_);
      last if $morpheme->is_eos;
      $current_chunk->add_morpheme($morpheme);
    }
  }
  $parsed_chunks{$current_chunk->id} = $current_chunk;
  delete $parsed_chunks{-1};

  my $root;
  for my $dependent_id (keys %dependency_ids) {
    my $dependent = $parsed_chunks{$dependent_id};
    my $dependency_id = $dependency_ids{$dependent_id}[0];
    if ($dependency_id == -1) {
      $root = $dependent;
    } else {
      $dependent->dependency($parsed_chunks{$dependency_id});
    }
  }
  return $root;
}

sub morpheme_parser { $_[0]->{morpheme_parser} }

sub parse {
  args
    my $self,
    my $filename => +{ isa => 'Str', optional => 1 },
    my $fh => +{ isa => 'FileHandle', optional => 1 },
    my $string => +{ isa => 'Str', optional => 1 };

  if (none { defined } ($filename, $fh, $string)) {
    Carp::croak('No source specified.');
  }
  $fh //= do {
    my $object;
    if (defined $filename) {
      $object = $filename;
    } else {
      utf8::encode($string) if utf8::is_utf8($string);
      $object = \$string;
    }
    open my $fh, '<:encoding(utf8)', $object or die $!;
    $fh;
  };

  my @parsed_chunks;
  push @parsed_chunks, $self->do_parse($fh) until eof $fh;
  return \@parsed_chunks;
}

1;

=head1 SYNOPSIS

    use Parse::KyotoCorpus;
    use Parse::KyotoCorpus::MorphemeParser::MeCab;
    my $parser = Parser::KyotoCorpus->new(
      morpheme_parser => Parse::KyotoCorpus::MorphemeParser::MeCab->new,
    );
    
    my $dependency_trees = $parser->parse(string => <<'EOT');
    * 0 1D 0/1 1.605266
    色彩	名詞,一般,*,*,*,*,色彩,シキサイ,シキサイ
    を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    * 1 2D 0/1 0.618589
    持た	動詞,自立,*,*,五段・タ行,未然形,持つ,モタ,モタ
    ない	助動詞,*,*,*,特殊・ナイ,基本形,ない,ナイ,ナイ
    * 2 3D 1/1 1.928068
    多	接頭詞,名詞接続,*,*,*,*,多,タ,タ
    崎	名詞,一般,*,*,*,*,崎,サキ,サキ
    * 3 6D 0/1 -1.078810
    つくる	動詞,自立,*,*,五段・ラ行,基本形,つくる,ツクル,ツクル
    と	助詞,接続助詞,*,*,*,*,と,ト,ト
    、	記号,読点,*,*,*,*,、,、,、
    * 4 5D 0/1 1.495519
    彼	名詞,代名詞,一般,*,*,*,彼,カレ,カレ
    の	助詞,連体化,*,*,*,*,の,ノ,ノ
    * 5 6D 0/1 -1.078810
    巡礼	名詞,サ変接続,*,*,*,*,巡礼,ジュンレイ,ジュンレイ
    の	助詞,連体化,*,*,*,*,の,ノ,ノ
    * 6 -1D 0/0 0.000000
    年	名詞,一般,*,*,*,*,年,トシ,トシ
    EOS
    EOT
    
    my @chunks = ($dependency_trees->[0]);
    while (my $chunk = shift @chunks) {
      my $surface = $chunk->surface;
      ...
    } continue {
      push @chunks, values %{ $chunk->dependents };
    }

=head1 DESCRIPTION

Parse::KyotoCorpus is a parser class for Kyoto Corpus-formatted data.

In natural language processing study, the format is used as a de-facto standard of annotated japanese language text. e.g., CaboCha and J.DepP, japanese dependency structure analyzers, are both able to output its analysis result as the format.

=head1 METHODS

=head2 new(morpheme_parser => $morpheme_parser)

Constructor. C<morpheme_parser> is an object that implements C<parse> method (see L<Parse::KyotoCorpus::MorphemeParser::MeCab>.)

=head2 parse(fh => $fh | filename => $path | string => $string)

Parse Kyoto Corpus-formatted input from given source.
Return value is an ArrayRef of L<Parse::KyotoCorpus::Chunk> objects. Each object represents a parsed result of sentence.

Available input sources are:

=over 4

=item C<fh> - A filehandle.

=item C<filename> - A path to a file containing Kyoto Corpus-formatted text.

=item C<string> - A scalar holding text.

=back

If the given source is unavailale (e.g., given file path doesn't exist,) this method will raise an error.

=head1 TODO

Currently this module has only poor input validation and is not robust against invalid data. So you can not use this module for error checking or process with untrusted data source.

=head1 SEE ALSO

=over 4

=item L<Parse::KyotoCorpus::Chunk>

=item L<Parse::KyotoCorpus::MorphemeParser::MeCab>

=item L<Parse::KyotoCorpus::Morpheme::MeCab>

=item L<CaboCha - Yet Another Japanese Dependency Structure Analyzer|http://code.google.com/p/cabocha/>

=item L<J.DepP - C++ implementation of Japanese Dependency Parsers|http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/jdepp/>

=back

=cut
