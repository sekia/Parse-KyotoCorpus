Parse-KyotoUniversityTextCorpus
===============================

This is a Perl module for parsing Kyoto University Text Corpus-formatted text.

Using this module, you can inspect/manipulate japanese syntactic structure outputted from [CaboCha](http://code.google.com/p/cabocha/) or other system.

Install
---

If [cpanm](https://metacpan.org/pod/App::cpanminus) have been installed on your system, simply:

```
cpanm http://sekia.github.io/Parse-KyotoUniversityTextCorpus-latest.tar.gz
```

Otherwise:

```
curl -kLO http://sekia.github.io/Parse-KyotoUniversityTextCorpus-latest.tar.gz
tar xzf Parse-KyotoUniversityTextCorpus-latest.tar.gz && cd Parse-KyotoUniversityTextCorpus-latest
perl Makefile PREFIX=/usr/local  # Set PREFIX wherever you want.
make && make test && make install
```

Usage
---

For detailed usage, refer `perldoc Parse::KyotoUniversityTextCorpus` after installing.

Example
---

```perl
#!/usr/bin/env perl

use v5.18;
use utf8;
use IPC::Open3;
use Parse::KyotoUniversityTextCorpus;
use Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab;
use Symbol qw//;

my ($in, $out, $err);
my $pid;

BEGIN {
  ($in, $out, $err) = (Symbol::gensym, Symbol::gensym, Symbol::gensym);
  $pid = open3($in, $out, $err, cabocha => '-f1');
}

END {
  close $out;
  close $err;
  waitpid $pid => 0 if defined $pid;
}

binmode STDOUT, ':encoding(utf8)';
binmode $in, ':encoding(utf8)';
binmode $out, ':encoding(utf8)';

my $parser = Parse::KyotoUniversityTextCorpus->new(
  morpheme_parser =>
    Parse::KyotoUniversityTextCorpus::MorphemeParser::MeCab->new,
);

say $in '星から出るのに、その子は渡り鳥を使ったんだと思う。';
say $in '出る日の朝、自分の星の片付けをした。';
close $in;
my $sentence_trees = $parser->parse(fh => $out);
for my $sentence_tree (@$sentence_trees) {
  for my $chunk (@{ $sentence_tree->as_arrayref }) {
    printf(
      "\%d: \%s -> \%d\n",
      $chunk->id,
      $chunk->surface,
      $chunk->is_root ? '-1' : $chunk->dependency->id,
    );
  }
  print "\n";
}
```

License
---

The MIT License (MIT)

Copyright (c) 2014 Koichi SATOH, all rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
