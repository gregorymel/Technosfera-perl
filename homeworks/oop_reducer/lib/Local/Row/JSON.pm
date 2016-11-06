package Local::Row::JSON;

use strict;
use warnings;
use Mouse;
use JSON::XS;

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

	return JSON::XS->new->utf8->decode($self->str);
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