package Local::MusicLibrary;

use strict;
use warnings;
no warnings 'experimental';
use 5.010;
use diagnostics;
use base qw( Exporter );
our @EXPORT_OK = qw( read_input_data );
our @EXPORT = qw( read_input_data );

###############################
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
###############################

our $VERSION = '1.00';

##########################################
sub parse_input_data {
	my $input_data = shift;

	my @data_base;
	for (@$input_data) {
		if ( m{
			^
				\. /
				(?<band>[^\/]+)
				/
				(?<year>\d+)
				\s+ - \s+
				(?<album>[^\/]+)
				/
				(?<track>.+)
				\.
				(?<format>[^\.]+)
			$
		}x ) {
			my %data_row = %+;
			push @data_base, \%data_row;
		}
		else {
			die "Incorrect sequence!";
		}
	}

	return \@data_base;
}

sub sort_by_param($$) {
	my ($param, $data_base) = @_;

	my @sorted_data;
	if ($param =~ /\d+/) { 
		@sorted_data = sort { $a->{$param} <=> $b->{$param} } @$data_base;
	}
	else {
		@sorted_data = sort { $a->{$param} cmp $b->{$param} } @$data_base;	
	}
	
	return \@sorted_data;
}

sub filter_by_param {
	my ($param, $name, $data_base) = @_;
	
	my @filtered_data;
	if ($param =~ /\d+/) {
		@filtered_data = grep { $_->{$param} == $$name } @$data_base;
	}
	else {
		@filtered_data = grep { $_->{$param} eq $$name } @$data_base;
	}

	return \@filtered_data;
}

sub choose_columns {
	my $column_types = shift;

	my @column_types =  split ',', $column_types;
	for (@column_types) {
		pod2usage(2) unless /album/
						 || /track/
						 || /format/
						 || /band/
						 || /year/;
	}

	return \@column_types;
}

sub read_input_data {
	my ($file) = @_;

	my $param = {};	
	GetOptions($param, 'help|?', "album=s", "track=s", "sort=s",
			   "format=s", "band=s", "year=i", 'columns=s')
		or pod2usage(2);

	pod2usage(1) if $param->{help};


	my @input_data;
	while (<$file>) {
		chomp( $_ );
		push @input_data, $_;
	}

	my @data_base = @{ parse_input_data(\@input_data) };

	my @columns_for_print;
	if (exists $param->{columns}) {
		@columns_for_print = choose_columns(\@data_base);
	}
	else {
		push @columns_for_print, qw(band year album track format);
	}
	delete $param->{columns};

	my $processed_data = \@data_base; 	
	$processed_data = sort_by_param($param->{sort}, $processed_data)
		if exists $param->{sort};
	delete $param->{sort};

	for (keys %$param) {
		$processed_data = filter_by_param($_, \$param->{$_}, $processed_data);
	}	

	return ($processed_data, \@columns_for_print);
}


1;

__END__
=head1 NAME

music_library - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

music_library [options]

Options:
	-help            brief help message
=head1 OPTIONS
	

=over 4

=item B<-help>

Print a brief help message and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input data and print it in right format

=cut
