package Local::Source::Array;

use strict;
use warnings;
use Mouse;

has 'array' => (
	is => 'ro',
	isa => 'ArrayRef',
	required => 1
);

has 'temp_array' => (
	is => 'rw',
	isa => 'ArrayRef',
	builder => '_build_temp_buf'
);

sub _build_temp_buf {
	my $self = shift;

	my @array = @{ $self->array };
	return \@array;
}

sub next {
	my $self = shift;

	return shift @{ $self->temp_array };
}

sub reset {
	my $self = shift;

	$self->temp_array($self->_build_temp_buf);
}

1;