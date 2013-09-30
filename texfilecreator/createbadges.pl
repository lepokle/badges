#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Basename;
use Cwd qw(realpath getcwd);

use lib realpath( realpath( dirname($0) ) );
use BadgeCreator;
use Badges::DataLoader;

# ------------------------
exit main();

# ------------------------

sub main {
	if ( @ARGV == 0 ) {
		print_usage();
		return 1;
	}

	my $datasource;
	my %ds_options;
	my $list_datasources;

	GetOptions(
		'help|usage'       => \&print_usage,
		'list-datasources' => \$list_datasources,
		'datasource=s'     => \$datasource,
		'option=s'         => \%ds_options
	);

	if ($list_datasources) {
		list_datasources();
	}
	elsif ( defined $datasource && $datasource !~ /^\s+$/ ) {
		return run_datasource( $datasource, %ds_options );
	}
	else {
		print_usage();
	}

	return 0;
}

sub print_usage {
	print "--help\t\t\tprint help\n";
	print "--list-datasources\tlist available datasources\n";
	print "--datasource\t\tuse the given datasource\n";
	print "--option\t\tuse for defining all datasource options\n";
	return 1;
}

sub list_datasources {
	my $data_loader = Badges::DataLoader->new;

	for my $datasource ( $data_loader->list_datasources() ) {
		$data_loader->load_datasource($datasource);
		print "$datasource:\n";
		my %ds_options = %{ $data_loader->get_options };
		if ( keys %ds_options > 0 ) {
			for my $key ( sort keys %ds_options ) {
				print "  $key" . " " x ( 15 - length($key) ) . "$ds_options{$key}\n";
			}
		}
		else {
			print "  no options\n";
		}
		print "\n";
	}

	return 1;
}

sub run_datasource {
	my ( $datasource, %ds_options ) = @_;
	my $badge_creator = BadgeCreator->new();

	#if ( !grep { $_ eq $datasource } $badge_creator->get_datasources() ) {
#		print STDERR "No such datasource: $datasource\n";
#		return 1;
	#}

	print STDERR "Use datasource $datasource\n";
	$badge_creator->datasource($datasource);
	#$badge_creator->set_datasource_options(%ds_options);
	my @persons = $badge_creator->get_label_data($ds_options{'file'});
	@persons = BadgeCreator::sort_by_name(@persons);

	print STDERR "Found " . @persons . " persons\n";
	for my $person (@persons) {
		my $name = $person->{'name'};
		#print STDERR "Name: " . $name . "\n";
		$name = BadgeCreator::mbox_name_words($name);

		my $company = $person->{'company'};
		$company = BadgeCreator::remove_whitespace_around_slash($company);
		$company = BadgeCreator::escape_chars_for_latex($company);
		$company = BadgeCreator::normalize_minus_company($company);

		my $line = "\\logolabel{$name}{$company}\n";
		# fix non breaking spaces by replacing them by spaces
		$line =~ s/\xa0/ /g;
		
		utf8::encode($line);
		print $line;
	}

	for ( my $i = 0 ; $i < 15 ; $i++ ) {
		print "\\logolabel{}{}\n";
	}

	return 1;
}

