package Badges::Datasource;
use Moose;

with 'MooseX::Object::Pluggable';

sub get_available_datasources {
	my ($self) = @_;
	my @plugins = $self->_plugin_locator->plugins;

	my $namespace = $self->_plugin_ns();
	@plugins = map { $_ =~ m/::${namespace}::(.*)$/; $1; } @plugins;
	@plugins = grep {
		my $datasource = Badges::Datasource->new;
		$datasource->load_plugin($_);
		$datasource->does('Badges::Datasource::Roles::IsDatasource');
	} @plugins;

	return @plugins;
}

no Moose;
1;
