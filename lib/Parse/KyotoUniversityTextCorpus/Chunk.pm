package Parse::KyotoUniversityTextCorpus::Chunk;

# ABSTRACT: Dependency structure representation.

use v5.10;
use Carp qw//;
use Parse::KyotoUniversityTextCorpus::Types;
use Scalar::Util qw//;
use Smart::Args;

sub new {
  args
    my $class => 'ClassName',
    my $dependency => +{ isa => __PACKAGE__, optional => 1 },
    my $dependency_type => +{
      isa => 'Parse::KyotoUniversityTextCorpus::DependencyType',
      optional => 1,
    },
    my $dependents => +{
      isa => sprintf('HashRef[%s]', __PACKAGE__),
      optional => 1,
    },
    my $id => 'Int',
    my $morphemes => +{
      isa => 'ArrayRef[Parse::KyotoUniversityTextCorpus::Morpheme]',
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
    my $morpheme => 'Parse::KyotoUniversityTextCorpus::Morpheme';

  push @{ $self->morphemes }, $morpheme;
}

sub as_arrayref {
  args
    my $self;

  unless ($self->is_root) {
    Carp::croak('as_arrayref() method works only on root chunk.');
  }

  $self->do_as_arrayref(\my @acc);
  [ sort { $a->id <=> $b->id } @acc ];
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
      isa => 'Parse::KyotoUniversityTextCorpus::DependencyType',
      optional => 1,
    };

  $self->{dependency_type} = $dependency_type if defined $dependency_type;
  return $self->{dependency_type};
}

sub dependents { $_[0]->{dependents} }

sub depends {
  args
    my $self,
    my $on => __PACKAGE__,
    my $transitive => +{ isa => 'Bool', default => 0 };

  return if $self->is_root;
  return 1 if $on->is_root;
  return 1 if $self->dependency == $on;
  return unless $transitive;
  $self->dependency->depends(on => $on, transitive => $transitive);
}

sub do_as_arrayref {
  args_pos
    my $self,
    my $acc => sprintf('ArrayRef[%s]', __PACKAGE__);

  push @$acc, $self;
  $_->do_as_arrayref($acc) for values %{ $self->dependents };
}

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

    use Parse::KyotoUniversityTextCorpus;
    
    my $parser = Parse::KyotoUniversityTextCorpus->new(...);
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

Normally you will get instances of this class as return value of L<Parse::KyotoUniversityTextCorpus>'s C<parse> method. The returned chunk is the root of a dependency tree of a sentence. You can traverse the dependency structure from the root chunk.

=head1 METHODS

=head2 as_arrayref

Returns an ArrayRef of chunks sorted in order of C<id>. This method works only on C<root> chunk.

=head2 dependency

Returns another chunk that this chunk depends on.

If the chunk is the C<root> of dependency tree, this method returns C<undef>.

=head2 dependency_type

Type of dependency. Which of C<"apposition">, C<"dependency"> and C<"parallel">.

=head2 dependents

HashRef of chunks which depend on this chunk. Its key is each chunk's C<id>.

=head2 depends(on => $chunk [, transitive => $bool])

Returns true if this chunk has a dependency on C<$chunk>. False otherwise.

If optional parameter C<transitive> is set true (false is default value,) this method searches dependency transitively. e.g., C<$chunk_a> depends on C<$chunk_b> and C<$chunk_b> depends on C<$chunk_c>, C<< $chunk_a->depends(on => $chunk_c) >> is false but C<< $chunk_a->depends(on => $chunk_c, transitive => 1) >> returns true.

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
