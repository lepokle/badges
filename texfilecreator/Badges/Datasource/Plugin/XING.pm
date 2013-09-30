package Badges::Datasource::Plugin::XING;
use Moose::Role;

# ---------------------------------------------
use WWW::Mechanize;
use HTML::TreeBuilder;

use vars qw($VERSION);
$VERSION = '0.1';

use Carp;
$Carp::Internal{ (__PACKAGE__) }++;

# ---------------------------------------------

with 'Badges::Datasource::Roles::IsDatasource', 'Badges::Datasource::Roles::HasOptions';

has 'username' => (
	is  => 'rw',
	isa => 'Str',
	traits => [ 'IsOption' ],
	description => 'username for login into XING',
	default => 'leo.vonklenze@tngtech.com'
);

has 'password' => (
	is  => 'rw',
	isa => 'Str',
	traits => [ 'IsOption' ],
	description => 'password for login into XING',
	default => '[snd@xing]'
);

has 'event' => (
	is  => 'rw',
	isa => 'Str',
	traits => [ 'IsOption' ],
	description => 'name of the event (copy from event URL)',
	default => 'treffen-atlassian-user-group-munchen-9-6-2011-17-00-20-00-767704'
);

sub get_label_data {
	my $self = shift;
	my $page;
	my @persons;

	$page = $self->_load_event_page('yes');
	push( @persons, $self->_extract_label_data($page) );

	return @persons;
}

sub _load_event_page {
	my ($self) = @_;

	my $mech = WWW::Mechanize->new();

	print STDERR "Start XING...\n";
	$mech->get('https://www.xing.com/');
	die "Cannot load login page https://www.xing.com!\n"
	  unless $mech->title() eq 'Business Network - Social Network for Business Professionals | XING';

	print STDERR "Login...\n";
	$mech->form_name('loginform');
	$mech->set_fields(
		'login_user_name' => 'leo.vonklenze@tngtech.com',
		'login_password'  => '[snd@xing]'
	);
	$mech->click();

	die "Cannot login to XING! Title is: " . $mech->title() . "\n"
	  unless $mech->title() eq 'Start | XING';

	print STDERR "Find Event 'treffen-atlassian-user-group-munchen-9-6-2011-17-00-20-00-767704'\n";
	my $event = 'treffen-atlassian-user-group-munchen-9-6-2011-17-00-20-00-767704';
	$mech->get(
		"https://www.xing.com/events/$event/guestlist?limit=200&participation[yes]&participation[maybe]");
	die "Cannot find event: $self->{'event'}\n" unless $mech->title() =~ m/^Event: /;

	return $mech->content();
}

sub _extract_label_data {
	my ( $self, $page ) = @_;
	my @persons;

	print STDERR "Extract usernames and company names...\n";
	my $html_root = HTML::TreeBuilder->new_from_content($page);

	my $user_table = $html_root->look_down( 'id', 'guestlist-table' );
	my @user_rows = $user_table->look_down( '_tag', 'tbody' )->look_down( '_tag', 'tr' );
	for my $user_row (@user_rows) {
		my $user_name_tag    = undef;
		my $user_company_tag = undef;

		if ( defined $user_row->look_down( 'class', qr/user-info/ ) ) {

			# normale users
			$user_name_tag = $user_row->look_down( 'class', qr/user-info/ )->look_down( 'href', qr/\/profile\// );
			$user_company_tag = $user_row->look_down( 'class', qr/user\-company/ );
		}
		elsif ( defined $user_row->look_down( 'class', qr/companion\-name/ ) ) {

			#companions
			$user_name_tag = $user_row->look_down( 'class', qr/companion\-name/ )->look_down( '_tag', 'strong' );
			$user_company_tag = $user_row->look_down( 'class', qr/companion\-company/ );
		}

		if ( defined $user_name_tag ) {
			my $person = { name => $user_name_tag->as_trimmed_text() };
			if ( defined $user_company_tag ) {
				$person->{'company'} = $user_company_tag->as_trimmed_text();
			}
			push( @persons, $person );
		}
	}
	return @persons;
}

no Moose;
1;
