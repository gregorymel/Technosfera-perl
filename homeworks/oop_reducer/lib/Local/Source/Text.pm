package Local::Source::Text;

use strict;
use warnings;
use Mouse;

has 'text' => (
	is => 'ro',
	isa => 'Str'

);

has 'delimiter' => (
	is => 'ro',
	isa => 'Str',
	default => "\n"
);

has 'array' => (
	is => 'ro',
	isa => 'ArrayRef',
	builder => '_handle_text'
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

sub _handle_text {
	my $self = shift;

	my @data_rows = split $self->delimiter, $self->text;
	return \@data_rows;
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