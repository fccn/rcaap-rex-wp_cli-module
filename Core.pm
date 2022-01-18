#
# Paulo Graça <paulo1978@gmail.com>
#
package Rex::CMS::WP_CLI::Core;

use strict;

use Rex::Commands;
use Rex::CMS::WP_CLI;
use Rex::Logger;
use Data::Dumper;

our $WP_CLI_COMMAND = 'core';

task "download" => sub {
   _execute(task->name, @_);
};

task "install" => sub {
	if (is_installed()) {
		Rex::Logger::info( "WP already installed, nothing to do", "warn" );
	} else {
		my $param = shift; 

		my $admin_user = $param->{'conf'}->{'admin_user'};
		my $admin_email = $param->{'conf'}->{'admin_email'};
		my $url = $param->{'conf'}->{'url'};
		my $title = $param->{'conf'}->{'title'};
		my $admin_password = $param->{'conf'}->{'admin_password'};

		my $command = "--url=$url --title=$title --admin_user=$admin_user --admin_password=$admin_password --admin_email=$admin_email " . $param->{'params'};
		_execute(task->name, $command);
	}
};

task "update" => sub {
   _execute(task->name, @_);
};

task "update_db" => sub {
   _execute(task->name, @_);
};

desc 'return 1 if not installed';
sub is_installed {	
	Rex::CMS::WP_CLI::execute ('core is-installed');
   return ($? == 0);
};

sub _execute {
   my ($task_name, $params) = @_;
   my @action = split(/\:/, $task_name);   
   
   Rex::CMS::WP_CLI::executeAction('', {
		  command => $WP_CLI_COMMAND,
		  action => $action[$#action],
		  parameters => $params,
		}
   );
};