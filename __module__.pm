package Rex::CMS::WP_CLI;

use strict;
use warnings;

# REX dependencies
use Rex -base;

use Rex::Logger;
use Rex::Config;

use Data::Dumper;

my %WP_CLI_CONF = ();

Rex::Config->register_set_handler("wp_cli" => sub {
   my ($name, $value) = @_;
   $WP_CLI_CONF{$name} = $value;
});

set wp_cli => source => "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar";
set wp_cli => target => "/usr/local/wordpress/wp-cli";
set wp_cli => symlink => "/usr/local/bin/wp";

desc "Install WordPress CLI tool";
task "setup" => sub {	
	my $target = $WP_CLI_CONF{target};
	my $source = $WP_CLI_CONF{source};
	my $symlink = $WP_CLI_CONF{symlink};
	
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

desc "Execute WordPress CLI tool";
task "executeAction" => sub {
   my $param = shift;  
   my $base_dir;
   my $key = (keys %{$param})[0];   
   my $symlink = $WP_CLI_CONF{symlink};
   
   die("You need to specify the wp path to be executed.") unless $base_dir  = $key ? $key : $WP_CLI_CONF{base_dir};	   
   die("You need to specify the command to be executed.") unless $param->{$key}->{command};
   die("You need to specify the action to be executed.") unless $param->{$key}->{action};
  
   if(! is_symlink($symlink) ) {
      Rex::Logger::info("WP-CLI requires instalation, first execute setup", "error");
	  die("Can't execute wp-cli");
   } else {
		Rex::Logger::info("Running: wp "
			. $param->{$key}->{command}
			.' '.$param->{$key}->{action}
			.' '.$param->{$key}->{parameters}
			.' --path=' .$base_dir);		
			
		run 'wp '.$param->{$key}->{command}
			.' '.$param->{$key}->{action}
			.' '.$param->{$key}->{parameters} 
			.' --path=' .$base_dir 
		;
		die("Error running wp command. Please check the base_dir param or if WP is installed.") unless ($? == 0);
		
   }
};


desc "Execute Full command WordPress CLI tool";
task "execute" => sub {
   my $param = shift;  
   my $base_dir;
   
   my $symlink = $WP_CLI_CONF{symlink};
   my $hasParamPathPos = index($param, '--path=');
   
   die("You need to specify the WP Path to execute.") unless $base_dir  =  $WP_CLI_CONF{base_dir};	   
  
   if(! is_symlink($symlink) ) {
      Rex::Logger::info("WP-CLI requires instalation, first execute setup", "error");
	  die("Can't execute wp-cli");
   } else {
	  my $pathParam = ($hasParamPathPos == -1) ? " --path=$base_dir" : '';
	  Rex::Logger::info("Running: wp $param $pathParam");
			
	  run "wp $param $pathParam";
	  return $?;
   }
};

=pod
=head1 NAME
Rex::CMS::WP_CLI - Wordpress CLI module for Rex, it permits to manage Wordpress install through the Command-Line Interface
=head1 USAGE
 rex -H $host Rex:CMS:WP_CLI:setup
Or, to use it as a library
 use Rex::CMS::WP_CLI;
 
 task "prepare", sub {
    Rex::CMS::WP_CLI::setup();
 };

=head1 TASKS

=over 4

=item setup
  Install WordPress CLI tool
  
=item execute
  This task will execute wp cli commands
  
     task "mytask", sub {
      Rex::CMS::WP_CLI::execute('/path_to_wordpress_website', {
		  command => 'theme',
		  action => 'install',
		  parameters => 'twentysixteen --activate',
		}
	  );
     }; 
 
1;
