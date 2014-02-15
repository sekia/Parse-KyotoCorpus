package Parse::KyotoCorpus::Chunk;

# ABSTRACT: Dependency structure representation.

use v5.14;
use Carp qw//;
use Parse::KyotoCorpus::Types;
use Scalar::Util qw//;
use Smart::Args;

sub new {
  args
    my $class => 'ClassName',
    my $dependency => +{ isa => __PACKAGE__, optional => 1 },
    my $dependency_type => +{
      isa => 'Parse::KyotoCorpus::DependencyType',
      optional => 1,
    },
    my $dependents => +{
      isa => sprintf('HashRef[%s]', __PACKAGE__),
      optional => 1,
    },
    my $id => 'Int',
    my $morphemes => +{
      isa => 'ArrayRef[Parse::KyotoCorpus::Morpheme]',
      optional => 1,
    };

  if (defined $dependency and not defined $dependency_type) {
    Carp::croak('dependency_type is undefined.');
  }
  Scalar::Util::weaken($dependency);
  $dependents //= +{};
  $morphemes //= [];
  bless +{
    dependency => $dependency,
    dependency_type => $dependency_type,
    dependents => $dependents,
    id => $id,
    morphemes => $morphemes,
  } => $class;
}

sub add_morpheme {
  args_pos
    my $self,
    my $morpheme => 'Parse::KyotoCorpus::Morpheme';

  push @{ $self->morphemes }, $morpheme;
}

sub dependency {
  args_pos
    my $self,
    my $dependency => +{ isa => __PACKAGE__, optional => 1 };

  if (defined $dependency) {
    Scalar::Util::weaken($self->{dependency} = $dependency);
    $dependency->dependents->{$self->id} = $self;
  }
  return $self->{dependency};
}

sub dependency_type {
  args_pos
    my $self,
    my $dependency_type => +{
      isa => 'Parse::KyotoCorpus::DependencyType',
      optional => 1,
    };

  $self->{dependency_type} = $dependency_type if defined $dependency_type;
  return $self->{dependency_type};
}

sub dependents { $_[0]->{dependents} }

sub id { $_[0]->{id} }

sub is_root { not defined $_[0]->dependency }

sub morphemes { $_[0]->{morphemes} }

sub root { $_[0]->is_root ? $_[0] : $_[0]->dependency->root }

sub siblings {
  args
    my $self;

  return +{} if $self->is_root;
  my %siblings = %{ $self->dependency->dependents };
  delete $siblings{$self->id};
  return \%siblings;
}

sub surface { join '', map { $_->surface } @{ $_[0]->morphemes } }

1;

=head1 SYNOPSIS

    use Parse::KyotoCorpus;
    
    my $parser = Parse::KyotoCorpus->new(...);
    my $results = $parser->parse(...);
    
    # Print simple dependency tree for each sentence.
    for my $result (@$results) {
        my @bfs = ([ $result => 0 ]);
        until (@bfs == 0) {
            my ($chunk, $indent_level) = @{ shift @bfs };
            say '    ' x $indent_level, $chunk->surface;
            push @bfs, map {
                [ $_ => $indent_level + 1 ]
            } sort { $a->{id} <=> $b->{id} } values %{ $chunk->dependents };
        }
    }

=head1 DESCRIPTION

This class represents a chunk of words recognized as a unit called bunsetsu (文節) in japanese language syntax.

Normally you will get instances of this class as return value of L<Parse::KyotoCorpus>'s C<parse> method. The returned chunk is the root of a dependency tree of a sentence. You can traverse the dependency structure from the root chunk.

=head1 METHODS

=head2 dependency

Returns another chunk that this chunk depends on.

If the chunk is the C<root> of dependency tree, this method returns C<undef>.

=head2 dependency_type

Type of dependency. the value depends on system that generated the source, even can be undefined.

=head2 dependents

HashRef of chunks which depend on this chunk. Its key is each chunk's C<id>.

=head2 id

ID digits that is unique in dependency tree.

=head2 is_root

Returns true if the chunk is the root of dependency tree (i.e., the last chunk of sentence.) false otherwise.

=head2 morphemes

ArrayRef of morphemes contained in the chunk.

=head2 root

Returns the root chunk of dependency tree.

=head2 siblings

Returns chunks that having same dependency of this chunk as a HashRef. Its key is each chunk's C<id>.

=head2 surface

Concatenated C<morphemes>' surfaces.

=cut
