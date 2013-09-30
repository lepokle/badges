package Badges::Datasource::Roles::HasNoOptions;
use Moose::Role;

sub get_options {
    return {};
}

no Moose;
1;
