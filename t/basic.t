use utf8;
use Test::More;

use_ok 'Parse::KyotoCorpus';
use_ok 'Parse::KyotoCorpus::MorphemeParser::MeCab';

my $morpheme_parser = new_ok 'Parse::KyotoCorpus::MorphemeParser::MeCab';
my $parser = new_ok 'Parse::KyotoCorpus' => [
  morpheme_parser => $morpheme_parser,
];

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

is 0 + @$dependency_trees, 1;

done_testing;
