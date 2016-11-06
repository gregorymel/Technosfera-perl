package Local::Reducer::MaxDiff;

use Mouse;
use strict;
use warnings;
with 'Local::Reducer';

has [qw(
	top
	bottom
)] => (
	is => 'ro',
	isa => 'Str'
);

sub reduce {
	my ($self, $item, $value) = @_;

	my $row = $self->row_class->new(str => $item);
	my $diff = abs($row->get($self->top, 0) 
				   - $row->get($self->bottom, 0));

	if ($diff > $value) {
		return $diff;
	}
	else {
		return $value;
	}
}

1;