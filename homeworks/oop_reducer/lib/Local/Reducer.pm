package Local::Reducer;

use strict;
use warnings;
use Mouse::Role;

requires 'reduce';

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

has 'source' => (
	is  => 'ro',
	isa => 'Object',
	required => 1,
);

has 'row_class' => (
	is  => 'ro',
	isa => 'ClassName',
	required => 1
);

has 'initial_value' => (
	is  => 'ro',
	isa => 'Any',
	required => 1
); 

has 'reduced' => (
	is => 'rw',
	isa => 'Any'
);


sub BUILD {
	my $self = shift;

	$self->source->can('next') 
		&& $self->row_class->can('get')
		&& $self->source->can('reset')
		or die "There aren't necessary methods!"; 
}

sub reduce_n($) {
	my ($self, $n) = @_;

	do {
		$self->source->reset;
		return $self->initial_value;
	} if $n == 0;

	my $item = $self->source->next 
	|| do {
		$self->source->reset;
		return $self->initial_value;
	};

	$self->reduced($self->reduce($item, $self->reduce_n(--$n)));
	return $self->reduced;
}

sub reduce_all {
	my $self = shift;

	my $item = $self->source->next 
	|| do {
		$self->source->reset;
		return $self->initial_value;
	};

	$self->reduced($self->reduce($item, $self->reduce_all()));
	return $self->reduced;	
}


1;