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

use DDP;

our $VERSION = '1.00';

##########################################
use enum qw/BAND YEAR ALBUM TRACK FORMAT/;

sub parse_input_data {
	my $input_data = shift;

	my @data_base;
	for ($$input_data) {
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
			$data_base[BAND] = $+{band};
			$data_base[YEAR] = $+{year};
			$data_base[ALBUM] = $+{album};
			$data_base[TRACK] = $+{track};
			$data_base[FORMAT] = $+{format};
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
	if ($param == YEAR) { 
		@sorted_data = sort { $a->[YEAR] <=> $b->[YEAR] } @$data_base;
	}
	else {
		@sorted_data = sort { $a->[$param] cmp $b->[$param] } @$data_base;	
	}
	
	return \@sorted_data;
}

sub filter_by_param {
	my ($param, $name, $data_base) = @_;
	
	my @filtered_data;
	if ($param == YEAR) {
		@filtered_data = grep { $_->[YEAR] == $$name } @$data_base;
	}
	else {
		@filtered_data = grep { $_->[$param] eq $$name } @$data_base;
	}

	return \@filtered_data;
}


sub formated_print {
	my $data_base = shift @_;
	
	return [] unless @$data_base;

	my @column_width;
	for my $param (@_) {
		my $max = length $$data_base[0][$param];
		for my $row (@$data_base) {
			$max = length $row->[$param] if $max < length $row->[$param];
		}
		push @column_width, $max;
	}
	
	#Calculate width of table
	my $width = 0;
	for (@column_width) {
		$width += ($_ + 2);
	}
	return if $width == 0;
	$width += (@column_width - 1); 
	#########################

	printf "\/%s\\\n", "-" x $width;

	my $col_count = 0; # column counter
	my $row_count = 0; # row counter
	for my $row (@$data_base) {

		print "|";
		$col_count = 0;
		for my $param (@_) {
			printf " %*s |", $column_width[$col_count], $row->[$param];
			$col_count++; 	
		}
		print "\n";

		do {
			print "|";
			$col_count = 0;
			for my $param (@_) {
				printf "-%s-", "-" x $column_width[$col_count];
				print "+" unless $col_count == $#column_width;
				$col_count++; 	
			}
			print "|";
			print "\n";
		} unless $row_count == $#$data_base;
		$row_count++; 			
	}

	printf "\\%s\/\n", "-" x $width;	
}


sub get_param_id {
	my $param_str = shift;

	my $param_id;
	given ( $param_str ) {
		when(/year/i)   { $param_id = YEAR };
		when(/album/i)  { $param_id = ALBUM };
		when(/format/i) { $param_id = FORMAT };
		when(/band/i)   { $param_id = BAND };
		when(/track/i)  { $param_id = TRACK };
		default         { $param_id = undef }; 
	}

	return $param_id;
}

sub read_input_data {

	my $param = {};	
	GetOptions($param, 'help|?', "album=s", "track=s", "sort=s",
			   "format=s", "band=s", "year=i", 'columns=s')
		or pod2usage(2);

	pod2usage(1) if $param->{help};


	my @data_base;
	while (<>) {
		chomp( $_ );
		push @data_base, parse_input_data(\$_);
	}


	my $processed_data = \@data_base;
	for (keys %$param) {
		next if (/columns/);		

		my $param_id;
		if (/sort/) {
			$param_id = get_param_id($param->{$_}); 
			pod2usage(2) unless defined( $param_id );		
			$processed_data = sort_by_param($param_id, $processed_data);
		}
		else {
			$param_id = get_param_id($_); 		
			$processed_data = filter_by_param($param_id, \$param->{$_}, $processed_data);
		}
	}


	@_ = ($processed_data);
	if (exists $param->{columns}) {
		my @column_param = split ',', $param->{columns};
		for (@column_param) {
			my $param_id = get_param_id($_);
			pod2usage(2) unless defined( $param_id );
			push @_, $param_id if defined $param_id;
		}
	}
	else {
		push @_, (BAND, YEAR, ALBUM, TRACK, FORMAT);
	}

	goto &formated_print;
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
