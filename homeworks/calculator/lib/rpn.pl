#!/usr/bin/env perl
=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;

	my $priority = {
		'U+' => '3',
		'U-' => '3',
		'^' => '3',
		'*' => '2',
		'/' => '2',
		'+' => '1',
		'-' => '1',
		'(' => '0',
	};
	
	my @buf = ();
	my $temp;
	for my $token (@{ $source }) {
		push @rpn, eval("$token * 1") if ($token =~ /\d/);
		push @buf, $token if ($token eq '(');
		
		given ($token) {
			# U+ or U- or ^
			when(/((U[+\-])|\^)/) {
				while ($temp = pop @buf) {
					if ($priority->{$temp} > $priority->{$1}) {
						push @rpn, $temp;
					}
					else { 
						push @buf, $temp;
						last; 
					}
				}
				push @buf, $1; 	
			}

			# * or \ or + or -
			when(/(^[+\-*\/])/) {
				while ($temp = pop @buf) {
					if ($priority->{$temp} >= $priority->{$1}) {
						push @rpn, $temp;
					}
					else {
						push @buf, $temp;
						last;
					}
				}
				
				push @buf, $1;
			}
			
			when(')') {
				while ($temp = pop @buf) {
					if ($temp ne '(') {
						push @rpn, $temp;
					}
					else { last; }
				}
				die "incorrect bracket sequence" unless $temp;	
			}
		} 
	}

	while ($temp = pop @buf) {
		if ($temp eq '(') {
			die "incorrect bracket sequence";
		}
		else {
			push @rpn, $temp;
		}
	}

	return \@rpn;
}

1;
