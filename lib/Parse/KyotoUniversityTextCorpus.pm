package Parse::KyotoUniversityTextCorpus;

# ABSTRACT: Parse Kyoto University Text Corpus-formatted text.

use v5.14;
use Carp qw//;
use List::MoreUtils qw/none/;
use Parse::KyotoUniversityTextCorpus::Chunk;
use Smart::Args;

our $VERSION = '0.01';

sub new {
  args
    my $class => 'ClassName',
    my $morpheme_parser => 'Parse::KyotoUniversityTextCorpus::MorphemeParser';

  bless +{ morpheme_parser => $morpheme_parser } => $class;
}

sub do_parse {
  args_pos
    my $self,
    my $fh => 'FileHandle';

  my %dependency_ids;
  my %parsed_chunks;
  my $current_chunk = Parse::KyotoUniversityTextCorpus::Chunk->new(id => -1);
  while (<$fh>) {
    chomp;
    next if /^#/;

    if (/^\*/) {  # Chunk header.
      $parsed_chunks{$current_chunk->id} = $current_chunk;
      my (undef, $chunk_id, $dependency_id) = split /\s+/;
      $current_chunk =
        Parse::KyotoUniversityTextCorpus::Chunk->new(id => $chunk_id);
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

    use Parse::KyotoUniversityTextCorpus;
    use Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab;
    my $parser = Parser::KyotoUniversityTextCorpus->new(
      morpheme_parser =>
        Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab->new,
    );
    
    my $dependency_trees = $parser->parse(string => <<'EOT');
    * 0 1D 0/1 3.105098
    星	名詞,一般,*,*,*,*,星,ホシ,ホシ
    から	助詞,格助詞,一般,*,*,*,から,カラ,カラ
    * 1 5D 0/1 0.911990
    出る	動詞,自立,*,*,一段,基本形,出る,デル,デル
    のに	助詞,接続助詞,*,*,*,*,のに,ノニ,ノニ
    、	記号,読点,*,*,*,*,、,、,、
    * 2 3D 0/0 1.554472
    その	連体詞,*,*,*,*,*,その,ソノ,ソノ
    * 3 5D 0/1 1.407575
    子	名詞,一般,*,*,*,*,子,コ,コ
    は	助詞,係助詞,*,*,*,*,は,ハ,ワ
    * 4 5D 0/1 2.049830
    渡り鳥	名詞,一般,*,*,*,*,渡り鳥,ワタリドリ,ワタリドリ
    を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    * 5 6D 2/4 0.911990
    使っ	動詞,自立,*,*,五段・ワ行促音便,連用タ接続,使う,ツカッ,ツカッ
    た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
    ん	名詞,非自立,一般,*,*,*,ん,ン,ン
    だ	助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ
    と	助詞,格助詞,引用,*,*,*,と,ト,ト
    * 6 -1D 0/0 0.000000
    思う	動詞,自立,*,*,五段・ワ行促音便,基本形,思う,オモウ,オモウ
    。	記号,句点,*,*,*,*,。,。,。
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

Parse::KyotoUniversityTextCorpus is a parser class for Kyoto University Text Corpus-formatted data.

In natural language processing study, the format is used as a de-facto standard of annotated japanese language text. e.g., CaboCha and J.DepP, japanese dependency structure analyzers, are both able to output its analysis result as the format.

=head1 METHODS

=head2 new(morpheme_parser => $morpheme_parser)

Constructor. C<morpheme_parser> is an object that implements C<parse> method (see L<Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab>.)

=head2 parse(fh => $fh | filename => $path | string => $string)

Parse Kyoto University Text Corpus-formatted input from given source.
Return value is an ArrayRef of L<Parse::KyotoUniversityTextCorpus::Chunk> objects. Each object represents a parsed result of sentence.

Available input sources are:

=over 4

=item C<fh> - A filehandle.

=item C<filename> - A path to a file containing Kyoto University Text Corpus-formatted text.

=item C<string> - A scalar holding text.

=back

If the given source is unavailale (e.g., given file path doesn't exist,) this method will raise an error.

=head1 TODO

Currently this module has only poor input validation and is not robust against invalid data. So you can not use this module for error checking or process with untrusted data source.

=head1 SEE ALSO

=over 4

=item L<Parse::KyotoUniversityTextCorpus::Chunk>

=item L<Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab>

=item L<Parse::KyotoUniversityTextCorpus::Morpheme::MeCab>

=item L<Kyoto University Text Corpus - KUROHASHI-KAWAHARA LAB|http://nlp.ist.i.kyoto-u.ac.jp/EN/index.php?Kyoto%20University%20Text%20Corpus>

=item L<CaboCha - Yet Another Japanese Dependency Structure Analyzer|http://code.google.com/p/cabocha/>

=item L<J.DepP - C++ implementation of Japanese Dependency Parsers|http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/jdepp/>

=back

=cut
