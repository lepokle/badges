package BadgeCreator;
use Moose;

# ---------------------------------------------
use Cwd qw(realpath);
use File::Basename;
use Module::Pluggable require => 1;

use vars qw($VERSION);
$VERSION = '0.1';

use Carp;
$Carp::Internal{ (__PACKAGE__) }++;

# ---------------------------------------------

has 'datasource' => (
	is      => 'rw',
	isa     => 'Str',
	handles => { 'get_datasource_options' => 'get_options',
		         'set_datasource_options' => 'set_options',
		         'get_label_data' => 'get_label_data' }
);

around 'datasource' => sub {
	my ( $original_method, $self, @parameters ) = @_;

	return $self->$original_method()
	  unless @parameters;

	my $plugin = 'Badges::Datasource::Plugin::' . $parameters[0];
	$plugin =~ s/::/\//g;
	$plugin .= '.pm';
	require $plugin;
	return $self->$original_method( 'Badges::Datasource::Plugin::' . $parameters[0] );
};

sub get_datasources {
	my ($self) = @_;
	my @plugins = $self->plugins();

	@plugins = map { m/::([^:]+)$/; $1; } @plugins;
	return @plugins;
}

sub remove_whitespace_around_slash {
	my ($text) = @_;
	$text =~ s#\s*/\s*#/#;
	return $text;
}

sub escape_chars_for_latex {
	my ($text) = @_;
	$text =~ s/\&/\\&/;
	return $text;
}

sub normalize_minus_company {
	my ($text) = @_;
	$text =~ s/^\-*$//;
	return $text;
}

sub mbox_name_words {
	my ($text) = @_;
	$text =~ s/\b([\w\.\-]+)(\s|\b$)/\\mbox{$1} /g;
	return $text;
}

sub sort_by_name {
	my (@persons) = @_;

	# since $person->{name} is "firstname name" we have to split the name first
	return ( sort { ( split / /, $a->{name}, 2 )[1] cmp( split / /, $b->{name}, 2 )[1]; } @persons );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
