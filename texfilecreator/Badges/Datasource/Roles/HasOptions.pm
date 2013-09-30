package Badges::Datasource::Roles::HasOptions;
use Moose::Role;

# ---------------------------------------------
use Array::Compare;
# ---------------------------------------------

sub set_options {
	my ( $self, %options ) = @_;

	my @attributes = sort $self->meta->get_attribute_list();
	my @missing_attribtues = Array::Compare->new->full_compare( [ sort keys %options ], [@attributes] );
	confess "Missing options needed for datasource: " . join( ', ', @attributes[@missing_attribtues] ) . "\n"
	  unless @missing_attribtues == 0;

	for my $key ( keys %options ) {
	    my $test = $self->meta->get_attribute($key);
	    $test->set_value($self, $options{$key} );
	}
	return 1;
}

sub get_options {
    my ( $self ) = @_;
    my $options = {};
    
    my @attributes = $self->meta->get_all_attributes();
    for my $attribute (@attributes) {
        if( $attribute->can('description') ) {
            $options->{$attribute->name} = $attribute->description;
        }	
    }
    	
  return $options;
}

no Moose;
1;
