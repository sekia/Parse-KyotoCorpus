package Parse::KyotoCorpus::Types;

use Mouse::Util::TypeConstraints;

enum 'Parse::KyotoCorpus::DependencyType'
  => [qw/apposition dependency parallel/];

duck_type 'Parse::KyotoCorpus::Morpheme'
  => [qw/as_string is_eos surface/];

duck_type 'Parse::KyotoCorpus::MorphemeParser' => [qw/parse/];

no Mouse::Util::TypeConstraints;

1;
