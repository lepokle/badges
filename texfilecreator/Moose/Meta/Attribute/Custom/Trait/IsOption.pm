package Moose::Meta::Attribute::Custom::Trait::IsOption;

use strict;
use warnings;

sub register_implementation { return 'Badges::Datasource::Roles::IsOption'; }

no Moose;
1;
