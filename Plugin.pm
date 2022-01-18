#
# Paulo Graça <paulo1978@gmail.com>
#
package Rex::CMS::WP_CLI::Plugin;

use strict;
use warnings;

use Data::Dumper;
use Rex::Commands;
use Rex::CMS::WP_CLI;

our $WP_CLI_COMMAND = 'plugin';

task "activate" => sub {
   _execute(task->name, @_);
};

task "deactivate" => sub {
   _execute(task->name, @_);
};

task "delete" => sub {
   _execute(task->name, @_);
};

task "install" => sub {   
   _execute(task->name, @_);
};

task "uninstall" => sub {
   _execute(task->name, @_);
};

task "update" => sub {
   _execute(task->name, @_);
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