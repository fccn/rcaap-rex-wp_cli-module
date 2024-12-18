#
# Paulo Graça <info@rcaap.pt>
#
package Rex::Module::CMS::WP_CLI::Theme;

use Rex::Commands;
use Rex::Module::CMS::WP_CLI;

our $WP_CLI_COMMAND = 'theme';

sub _execute {
	my @params = @_;

	my $param;
	if ( ref $params[0] eq "HASH" ) {
		$param = $params[0];
	} else {
		$param = {@params};
	}

	my @action = split(/\:/, $param->{task});

	Rex::Module::CMS::WP_CLI::execute (
		Rex::Module::CMS::WP_CLI::buildCommand(
			command => $WP_CLI_COMMAND,
			subcommand => $action[$#action],
			parameters => $param,
		), $param );
};


my @subcommands = qw( install delete activate update );
foreach my $subcommand (@subcommands) {
	desc "$subcommand $WP_CLI_COMMAND";
	task "$subcommand",
		sub {
			_execute(
				task => task->name,
				subparams => @_);
		};
}

desc "alias for install";
task "setup" => sub {
	_execute('install', @_);
};
