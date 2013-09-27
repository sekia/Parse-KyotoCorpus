package Parse::KyotoCorpus::Chunk;

use v5.14;
use Carp qw//;
use Parse::KyotoCorpus::Types;
use Scalar::Util qw//;
use Smart::Args;

sub new {
  args
    my $class => 'ClassName',
    my $dependency => +{ isa => __PACKAGE__, optional => 1, },
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
    my $dependency => +{ isa => __PACKAGE__, optional => 1, };

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
