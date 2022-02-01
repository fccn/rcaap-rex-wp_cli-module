#
# Paulo Graça <paulo1978@gmail.com>
#
package Rex::Module::CMS::WP_CLI::Core;

use strict;

use Rex::Commands;
use Rex::Module::CMS::WP_CLI;
use Rex::Logger;
use Data::Dumper;

our $WP_CLI_COMMAND = 'core';

my @subcommands = qw( download update update_db );
foreach my $subcommand (@subcommands) {
	desc "$subcommand $WP_CLI_COMMAND";
	task "$subcommand",
		sub {
			_execute(
				task => task->name,
				subparams => @_);
		};
}

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
		_execute(
			task => task->name,
			subparams => $command);
	}
};

task "multisite_install" => sub {
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
		_execute(
			task => task->name,
			subparams => $command);
	}
};

desc 'return 1 if not installed';
sub is_installed {
	Rex::Module::CMS::WP_CLI::execute ('core is-installed');
	return ($? == 0);
};


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