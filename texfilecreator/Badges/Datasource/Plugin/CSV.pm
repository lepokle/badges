package Badges::Datasource::Plugin::CSV;
use Moose::Role;

# ---------------------------------------------
use Text::CSV;

use vars qw($VERSION);
$VERSION = '0.1';

use Carp;
$Carp::Internal{ (__PACKAGE__) }++;

# ---------------------------------------------

with 'Badges::Datasource::Roles::IsDatasource', 'Badges::Datasource::Roles::HasOptions';

has 'file' => (
	traits      => ['IsOption'],
	is          => 'rw',
	isa         => 'Str',
	description => 'csv file to read (format: name,company)'
);

sub get_label_data {
	my ($self, $file) = @_;
	my @rows = $self->_load_rows($file);

	return $self->_create_label_data_from_rows(@rows);
}

sub _load_rows {
	my ( $self, $file, @rows ) = @_;

	my $csv = Text::CSV->new(
		{
			binary           => 1,
			allow_whitespace => 0
		}
	) or die "Cannot use CSV: " . Text::CSV->error_diag();

	open my $fh, "<:encoding(utf8)", $file or die "Cannot open file $file: $!";
	while ( my $row = $csv->getline($fh) ) {
		push( @rows, $row ) unless @{$row} < 2;
	}
	$csv->eof or $csv->error_diag();
	close $fh;

	return @rows;
}

sub _create_label_data_from_rows {
	my ( $self, @rows ) = @_;
	my @persons;

	for my $row (@rows) {
	    my $name = $row->[0];
		push( @persons, { name => $name, company => $row->[1] } );
	}

	return @persons;
}

no Moose;
1;
