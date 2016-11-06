package Local::Row::Simple;

use strict;
use warnings;
use Mouse;	

has 'str' => (
	is => 'ro',
	isa => 'Str',
	required => 1
);

has 'data' => (
	is => 'ro',
	isa => 'HashRef',
	builder => '_handle_str'
);

sub _handle_str {
	my $self = shift;

	my %data = split /[,:]/, $self->str;

	return \%data;
}

sub get {
	my ($self, $name, $default) = @_;

	if (exists $self->data->{$name}) {
		return $self->data->{$name};
	}
	else {
		return $default;
	}
}

1;