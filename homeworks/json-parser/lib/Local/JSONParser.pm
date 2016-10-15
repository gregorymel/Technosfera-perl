package Local::JSONParser;

use strict;
use 5.010;
use warnings;
no warnings 'experimental';
use diagnostics;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );


my $pos;

sub match($$) {
	my ($reg_exp, $source) = @_;

	pos $source = $pos;
	my @match_res = ($source =~ $reg_exp);
	$pos += length $& if defined $&;	
	
	if (wantarray) {
		return @match_res;	
	} 
	elsif (@match_res) {
		return 1;
	}

	0;
}


sub parse_json {
	my $source = shift;
	my $value_ref;	
	
	$pos = 0;

	eval {
		die "Can't parse!" unless ($value_ref = parse_value($source));
	1} or do {
		die  "Error: $@";			
	};	

	return $value_ref;
}


sub parse_object {
	my $source = shift;
	my %object = ();
	
	return undef unless match(qr/\G\s*\{\s*/, $source);
	my $was_bracket = 1;

	do {
		my $key;
		if (defined ($key = parse_string($source))) {			
			$was_bracket = 0;
			die "Can't parse object!"
				unless match(qr/\G\s*[\:]\s*/, $source);

			my $value = parse_value($source);
			die "Can't parse object!" unless defined $value;

			$object{$key} = $value;
		}
		elsif (!$was_bracket) {
			die "Unrecognized item!";
		}
		
	} while (match (qr/\G\s*,\s*/, $source));

	die "Can't parse object!" unless match(qr/\G(\s*\}\s*)/, $source);

	return \%object;
}


sub parse_string {
	my $source = shift;
	
	my @matches = match( 
		qr/
			\G
			"
			(
				(?:
					[^"\\\\]*
					|
					\\["\\\\bfnrt\/]
					|
					(
						\\u[0-9a-f]{4}
					)
				)*
			)
			"
		/x,
		$source);
	if (@matches) {
		my $return_str = shift @matches;
		$return_str =~ s/\\u([0-9a-f]{4})/\\x{$1}/g;
		return $return_str;
	}	

	undef;
}

sub parse_number {
	my $source = shift;

	my @matches = match( 
		qr/
		\G
		(
			[+\-]?
			\d+
			(?:\.\d*)?
			|
			\.
			\d+
		)
		/x,
	 	$source);

	if (@matches) {
		my $result = shift @matches;
		my @exponent = match(qr/\G(e[+-]?\d+)/, $source);
		$result .= shift @exponent if @exponent;
		return $result;	
	}

	undef;
}

sub parse_array {
	my $source = shift;
	my @array = ();

	return undef
		 unless match(qr/\G\s*\[\s*/, $source);
	my $was_bracket = 1;

	do {
		my $value;
		eval {
			$value = parse_value($source);
		1} or do {
			die "Unrecognized item!" unless $was_bracket;			
		};

		if (defined $value) {
			push @array, $value;
			$was_bracket = 0;
		}
	}
	while ( match(qr/\G\s*,\s*/, $source));

	die "Can't parse array!" unless match(qr/\G(\s*\]\s*)/, $source);
	
	return \@array;		
}

sub parse_value {
	my $source = shift;
	my $value;

	unless ($value = parse_object($source)) {
		unless ($value = parse_array($source)) {
			unless ($value = parse_string($source)) {
				unless ($value = parse_number($source)) {
					die "Unrecognized symbol!";
				}
			} 
		}
	} 	

	return $value;
}

1;
