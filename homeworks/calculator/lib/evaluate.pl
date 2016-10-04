=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;

	my @buffer;
	my $op;
	for (@{ $rpn }) {
		given ($_) {
			when(/\d/) { push @buffer, $_; }
			when(/U([\-])/) {
				$buffer[$#buffer] *= -1;
			}
			when(/(^[*+\-\/\^])/) {
				my $arg2 = pop @buffer;
				my $arg1 = pop @buffer;
				if ($1 eq '^') {
					$op = '**';
				}
				else {
					$op = $1;
				}
				push @buffer, eval "$arg1 $op $arg2";
				die $@ if $@;
			}
		}	
	}	

	return pop @buffer;
}

1;
