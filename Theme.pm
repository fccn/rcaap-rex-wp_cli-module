#
# Paulo Graça <paulo1978@gmail.com>
#
package Rex::Module::CMS::WP_CLI::Theme;

use Rex::Commands;
use Rex::Module::CMS::WP_CLI;

our $WP_CLI_COMMAND = 'theme';

task "activate" => sub {
  _execute(task->name, @_);
};

task "delete" => sub {
   _execute(task->name, @_);
};

task "install" => sub {
   _execute(task->name, @_);
};

task "update" => sub {
   _execute(task->name, @_);
};

sub _execute {
   my ($task_name, $params) = @_;
   my @action = split(/\:/, $task_name);   
   
   Rex::Module::CMS::WP_CLI::executeAction('', {
		  command => $WP_CLI_COMMAND,
		  action => $action[$#action],
		  parameters => $params,
		}
   );
};