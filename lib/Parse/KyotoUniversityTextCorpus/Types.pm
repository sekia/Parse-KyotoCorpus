package Parse::KyotoUniversityTextCorpus::Types;

use Mouse::Util::TypeConstraints;

enum 'Parse::KyotoUniversityTextCorpus::DependencyType'
  => [qw/apposition dependency parallel/];

duck_type 'Parse::KyotoUniversityTextCorpus::Morpheme'
  => [qw/as_string is_eos surface/];

duck_type 'Parse::KyotoUniversityTextCorpus::MorphemeParser' => [qw/parse/];

no Mouse::Util::TypeConstraints;

1;
