package Badges::Datasource::Roles::IsOption;
use Moose::Role;

has 'description' => (
	is  => 'ro',
	isa => 'Str',
);

no Moose;
1;
