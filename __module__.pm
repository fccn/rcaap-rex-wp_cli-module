package Rex::Module::CMS::WP_CLI;

use strict;
use warnings;

# REX dependencies
use Rex -base;

use Rex::Logger;
use Rex::Config;

use Data::Dumper;

our $setup_source = "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar";
our $wp_command = "/usr/local/bin/wp";
our $setup_target = "/usr/local/wordpress/wp-cli";

desc "Install WordPress CLI tool";
task "setup" => sub {
	my $target = param_lookup ("target", $setup_target);
	my $source = param_lookup ("source", $setup_source);
	my $symlink = param_lookup ("command", $wp_command);
	
	# verify if php is installed
	if(! is_installed("php") ) {
		die("PHP is required.");
	}

	if(! is_installed("wget") ) {
		pkg "wget",
			ensure    => "latest",
			on_change => sub { Rex::Logger::info("Updated wget package"); };
	}

	# Create source dir if it doesn't exists
	file $target, ensure => "directory";

	# download compressed source file
	run 'wget '.$source.' -O '.$target.'/wp-cli.phar';
	chmod 755, $target.'/wp-cli.phar';

	if(! is_symlink($symlink) ) {
		ln ($target.'/wp-cli.phar', $symlink);
	}

	Rex::Logger::info("WP-CLI successfully installed");
};

sub buildCommand {
	my @params = @_;
	my $param;
	if ( ref $params[0] eq "HASH" ) {
		$param = $params[0];
	}
	else {
		$param = {@params};
	}

	die("You need to specify the command to be executed.") unless $param->{command};
	die("You need to specify the action to be executed.") unless $param->{subcommand};

	return $param->{command}
				.' '.$param->{subcommand}
				.' '.$param->{parameters}->{subparams}
				.' '.$param->{parameters}->{params};
};

=head2 Usage
	Rex::Module::CMS::WP_CLI ("help");
	# list configurations
	Rex::Module::CMS::WP_CLI ("config list");
=cut

# Execute Full command WordPress CLI tool
sub execute {
	my $params = shift;
	my $command;
	my $env;
	
	if ( ref $params eq 'HASH' ) {
		$command = (keys %{$params})[0];
		if (ref $params->{$command}->{'env'} eq 'HASH' ) {
			$env = $params->{$command}->{'env'};
		} else {
			$env = {$params->{$command}->{'env'}};
		}

	} else {
		$command = $params;
	}

	my $base_dir;
	my $hasParamPathPos = index($command, '--path=');

	die("You need to specify the WP Path to execute.") unless $base_dir  =  param_lookup ("base_dir", '/var/www/html');

	my $pathParam = ($hasParamPathPos == -1) ? " --path=$base_dir" : '';
	Rex::Logger::info("Running: wp $command $pathParam");

	run 'wp',
		command => param_lookup ("command", $wp_command).' '. "$command $pathParam",
		continuous_read => sub {
			#output to log
			Rex::Logger::info(@_);
		},
		env => $env;

	die("Error running wp command. Please check the base_dir param or if WP is installed.") unless ($? == 0);

	return $?;
};

=pod
=head1 NAME
Rex::Module::CMS::WP_CLI - Wordpress CLI module for Rex, it permits to manage Wordpress install through the Command-Line Interface
=head1 USAGE
 rex -H $host Module:CMS:WP_CLI:setup
Or, to use it as a library
 use Rex::Module::CMS::WP_CLI;
 
 task "prepare", sub {
    Rex::Module::CMS::WP_CLI::setup();
 };

=head1 TASKS

=over 4

=item setup
  Install WordPress CLI tool
  
=item execute
  This task will execute wp cli commands
  
     task "mytask", sub {
      Rex::Module::CMS::WP_CLI::execute('/path_to_wordpress_website', {
		  command => 'theme',
		  action => 'install',
		  parameters => 'twentysixteen --activate',
		}
	  );
     }; 
 
1;
