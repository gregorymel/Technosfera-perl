#!/usr/bin/env perl

use strict;
no strict 'subs';
use warnings;
use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Local::MusicLibrary;
use Local::TablePrinter;

my ($processed_data, $columns_for_print) = read_input_data(STDIN);

my %table_attributes = (
	row_separator => '-',
	column_separator => '|',
	table_nodes => '+',
	column_pattern => $columns_for_print
);

my $formated_print = print_table(\%table_attributes);
$formated_print->($processed_data);