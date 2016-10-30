package Local::TablePrinter;

use strict;
use warnings;
no warnings 'experimental';
use 5.010;
use base qw( Exporter );
our @EXPORT_OK = qw( print_table );
our @EXPORT = qw( print_table );

sub is_valid {
	my $attr_ref = shift;

	if (ref $attr_ref eq "HASH") {
		die "Invalid arguments"
			unless exists($attr_ref->{row_separator}) 
				   && defined($attr_ref->{row_separator})
				   and
				   exists($attr_ref->{column_separator}) 
				   && defined($attr_ref->{column_separator})
				   and
				   exists($attr_ref->{table_nodes}) 
				   && defined($attr_ref->{table_nodes})
				   and
				   exists($attr_ref->{column_pattern}) 
				   && defined($attr_ref->{column_pattern});
	}
	else {
		die "ref isn't ref to HASH";
	}
}

sub print_table {
	my ($table_attributes) = @_;
	is_valid($table_attributes);

	return sub($) {
		my $data_base = shift;

		return [] unless @$data_base;

		my @column_width;
		for my $param (@{ $table_attributes->{column_pattern} }) {
			my $max = length $$data_base[0]->{$param};
			for my $row (@$data_base) {
				$max = length $row->{$param} 
					if $max < length $row->{$param};
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
		my $separating_row = $table_attributes->{column_separator};
		$separating_row .= join $table_attributes->{table_nodes}, map {
			sprintf "%s", $table_attributes->{row_separator} x ($_ + 2)
		} @column_width;
		$separating_row .= $table_attributes->{column_separator};

		printf "\/%s\\\n", $table_attributes->{row_separator} x $width;

		my $col_count = 0; # column counter
		for my $row (@$data_base) {
			say $table_attributes->{column_separator}
				. join ( $table_attributes->{column_separator}, map {
					sprintf " %*s ", $column_width[$_], 
							$row->{${ $table_attributes->{column_pattern} }[$_]}
				  } 0..$#column_width )
				. $table_attributes->{column_separator};

			say $separating_row unless $row eq $$data_base[$#$data_base]; 			
		}

		printf "\\%s\/\n", $table_attributes->{row_separator} x $width;
	}	
}

1;