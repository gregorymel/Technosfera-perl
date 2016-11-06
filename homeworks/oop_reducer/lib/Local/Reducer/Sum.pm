package Local::Reducer::Sum;

use Mouse;
use strict;
use warnings;
with 'Local::Reducer';

has 'field' => (
	is  => 'ro',
	isa => 'Str'
);

sub reduce {
	my ($self, $item, $value) = @_;

	my $row = $self->row_class->new(str => $item);

	return $row->get($self->field, 0) + $value;
}

1;