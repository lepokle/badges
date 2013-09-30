package Badges::DataLoader;
use Moose;

use Badges::Datasource;

has 'datasource' => (
	is      => 'rw',
	isa     => 'Badges::Datasource',
	default => sub { Badges::Datasource->new },
	handles => {
		'list_datasources' => 'get_available_datasources',
		'get_options' => 'get_options',
		'get_data' => 'get_label_data'
	}
);

sub load_datasource {
	my ($self, $plugin) = @_;
	
	$self->datasource(Badges::Datasource->new);
	$self->datasource->load_plugin($plugin);
	
	return $self->does('Badges::Datasource::Roles::IsDatasource');
}   

no Moose;
1;
