use strict;
use warnings;
use utf8;
use Test::More;

use_ok 'Parse::KyotoCorpus';
use_ok 'Parse::KyotoCorpus::MorphemeParser::MeCab';

my $morpheme_parser = new_ok 'Parse::KyotoCorpus::MorphemeParser::MeCab';
my $parser = new_ok 'Parse::KyotoCorpus' => [
  morpheme_parser => $morpheme_parser,
];

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

is 0 + @$dependency_trees, 1;

my $root = $dependency_trees->[0];
my $chunks = $root->as_arrayref;
is 0 + @$chunks, 7;
is_deeply(
  [ map { $_->surface } @$chunks ],
  [ qw/星から 出るのに、 その 子は 渡り鳥を 使ったんだと 思う。/ ],
);

my $chunk5 = $chunks->[5];  # "使ったんだと"
ok not $chunk5->is_root;
is_deeply(
  $chunk5->dependents,
  +{
    1 => $chunks->[1],  # "出るのに、"
    3 => $chunks->[3],  # "子は"
    4 => $chunks->[4],  # "渡り鳥を"
  },
);
ok $chunk5->dependency == $chunks->[6];  # "思う。"
ok $chunk5->root == $chunks->[6];

my $chunk2 = $chunks->[2];  # "その"
# "その" depends on "子は." And "子は" depends on "使ったんだと."
ok not $chunk2->depends(on => $chunk5);
ok $chunk2->depends(on => $chunk5, transitive => 1);

done_testing;
