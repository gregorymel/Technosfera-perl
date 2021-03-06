use strict;
use warnings;

use Test::More tests => 11;

sub test_bin {
    my ($name, $params, $input, $output) = @_;

    open(my $input_fh, '>', 'input.tmp');
    $input_fh->print($input);
    $input_fh->close();

    system("$^X bin/music_library.pl $params < input.tmp > output.tmp");

    my $real_output;
    {
        local $/ = undef;
        open(my $output_fh, '<', 'output.tmp');
        $real_output = <$output_fh>;
        $output_fh->close();
    }

    is($real_output, $output, $name);

    unlink('input.tmp');
    unlink('output.tmp');
}

test_bin
'basic', '',
<<INPUT
./Band/123 - Album/track.mp3
./B/3210 - AlbumAlbum/t.format
INPUT
,
<<OUTPUT
/-------------------------------------------\\
| Band |  123 |      Album | track |    mp3 |
|------+------+------------+-------+--------|
|    B | 3210 | AlbumAlbum |     t | format |
\\-------------------------------------------/
OUTPUT
;

test_bin
'no rows', '--band UNKNOWN',
<<INPUT
./B/3210 - AlbumAlbum/x.format
INPUT
,
<<OUTPUT
OUTPUT
;

test_bin
'filter', '--band B',
<<INPUT
./Band/123 - Album/track.mp3
./B/3210 - AlbumAlbum/t.format
./B/3210 - AlbumAlbum/x.format
INPUT
,
<<OUTPUT
/------------------------------------\\
| B | 3210 | AlbumAlbum | t | format |
|---+------+------------+---+--------|
| B | 3210 | AlbumAlbum | x | format |
\\------------------------------------/
OUTPUT
;

test_bin
'int filter', '--year 210',
<<INPUT
./B/0210 - AlbumAlbum/t.format
./B/210 - AlbumAlbum/x.format
./B/310 - AlbumAlbum/x.format
INPUT
,
<<OUTPUT
/------------------------------------\\
| B | 0210 | AlbumAlbum | t | format |
|---+------+------------+---+--------|
| B |  210 | AlbumAlbum | x | format |
\\------------------------------------/
OUTPUT
;

test_bin
'sort', '--sort format',
<<INPUT
./B/210 - AlbumAlbum/m.mp3
./B/210 - AlbumAlbum/o.ogg
./B/210 - AlbumAlbum/a.abc
INPUT
,
<<OUTPUT
/--------------------------------\\
| B | 210 | AlbumAlbum | a | abc |
|---+-----+------------+---+-----|
| B | 210 | AlbumAlbum | m | mp3 |
|---+-----+------------+---+-----|
| B | 210 | AlbumAlbum | o | ogg |
\\--------------------------------/
OUTPUT
;

test_bin
'int sort', '--sort year',
<<INPUT
./B/10 - AlbumAlbum/m.mp3
./B/100 - AlbumAlbum/o.ogg
./B/20 - AlbumAlbum/a.abc
INPUT
,
<<OUTPUT
/--------------------------------\\
| B |  10 | AlbumAlbum | m | mp3 |
|---+-----+------------+---+-----|
| B |  20 | AlbumAlbum | a | abc |
|---+-----+------------+---+-----|
| B | 100 | AlbumAlbum | o | ogg |
\\--------------------------------/
OUTPUT
;

test_bin
'columns', '--columns year,band,year',
<<INPUT
./B/1 - A/m.mp3
./B/2 - B/o.ogg
./B/3 - C/a.abc
INPUT
,
<<OUTPUT
/-----------\\
| 1 | B | 1 |
|---+---+---|
| 2 | B | 2 |
|---+---+---|
| 3 | B | 3 |
\\-----------/
OUTPUT
;

test_bin
'no columns', q{--columns ''},
<<INPUT
./B/1 - A/m.mp3
./B/2 - B/o.ogg
./B/3 - C/a.abc
INPUT
,
<<OUTPUT
OUTPUT
;

test_bin
'with spaces', q{--band ' A  B '},
<<INPUT
./ A  B /1 - A/m.mp3
./ A B /1 - A/m.mp3
./A  B/1 - A/m.mp3
./A  B /1 - A/m.mp3
./ A  B/1 - A/m.mp3
INPUT
,
<<OUTPUT
/--------------------------\\
|  A  B  | 1 | A | m | mp3 |
\\--------------------------/
OUTPUT
;

test_bin
'with dashes', q{--band '--A-B--C--'},
<<INPUT
./ABC/1 - A/m.mp3
./--A-B--C--/1 - A/m.mp3
./-A-B-C-/1 - A/m.mp3
./--ABC--/1 - A/m.mp3
./-AB-C-/1 - A/m.mp3
INPUT
,
<<OUTPUT
/------------------------------\\
| --A-B--C-- | 1 | A | m | mp3 |
\\------------------------------/
OUTPUT
;

test_bin
'several filters', '--band B --year 12',
<<INPUT
./B/1 - A/m.mp3
./A/12 - B/t.flac
./B/012 - AB/s.ogg
./B/12 - B/o.ogg
./A/12 - A/A.A
./B/3 - C/a.abc
INPUT
,
<<OUTPUT
/------------------------\\
| B | 012 | AB | s | ogg |
|---+-----+----+---+-----|
| B |  12 |  B | o | ogg |
\\------------------------/
OUTPUT
;
