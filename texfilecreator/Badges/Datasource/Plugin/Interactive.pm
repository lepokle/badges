package Badges::Datasource::Plugin::Interactive;
use Moose::Role;

# ---------------------------------------------
use Text::CSV;

use vars qw($VERSION);
$VERSION = '0.1';

use Carp;
$Carp::Internal{ (__PACKAGE__) }++;

# ---------------------------------------------

with 'Badges::Datasource::Roles::IsDatasource', 'Badges::Datasource::Roles::HasNoOptions';

sub get_label_data {
	my ($self) = @_;
	return ();
}

no Moose;
1;
