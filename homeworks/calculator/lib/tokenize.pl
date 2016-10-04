=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize {
	chomp(my $expr = shift);
	my @res;
	
	my $prev = '+';
	for ($expr) {
		pos = 0;

		while (pos($_) < length) {
			given ($_) {
				when(/\G\s+/gc) {}

				when(/\G([+-])/gc) {
					my $sign = $1;
					if ($prev =~ /^[+\-*\^\/(]/) {
						push @res, "U".$sign; 
						$prev = $sign;
					}
					else {
						push @res, $sign;
						$prev = $sign;
					}
				}

				when(/\G(\d+(\.\d*)?|\.\d+)/gc) {
					die "incorrect sequence" if $prev =~ /\d/;
					my $mantissa = $1;
					if (/\G(e[+-]?\d+)/gc) {
						push @res, $mantissa.$1;
						$prev = $mantissa.$1; 	
					}
					else {
						push @res, $mantissa;
						$prev = $mantissa;	
					}
				}

				when(/\G([*\^\/])/gc) {
					my $bop = $1;
					if ($prev =~ /[*\^\/+\-(]$/) {
						die "incorrect sequence";
					}
					push @res, $bop;
					$prev = $bop;
				}
				
				when(/\G([()])/gc) {
					my $bracket = $1;
					if ($bracket eq ')') {
						die "incorrect sequence" unless $prev =~ /\d|\)/;
					}
					else {
						die "incorrect sequence" if $prev =~ /\d/;
					}
					push @res, $bracket;
					$prev = $bracket;					
				}

				default {
					die "unidentified symbol"; 
				}		
			}
		}
	}

	die "incorrect sequence" unless $prev =~ /\d|\)/; 

	return \@res;
}

1;
