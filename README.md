# Rex wp_cli module
A Rex wrapper module for WP_CLI (Wordpress Command Line Interface)

# Usage

Include it in your project meta.yaml
```
Require:
    Rex::Module::CMS::WP_CLI:
        git: https://github.com/fccn/rcaap-rex-wp_cli-module.git
        branch: main
```

please do a `rexify --resolve-deps` after adding it

## Directly from CLI

You can execute it directly from the command line (please mind to firstly include `use Rex::Module::CMS::WP_CLI;` in your Rexfile):
```
rex -H $host Module:CMS:WP_CLI:setup
```

## From your project

You can use it without parameters - it will use configured CMDB settings
```
 use Rex::Module::CMS::WP_CLI;
 use Rex::Module::CMS::WP_CLI::Core;
    
 task "prepare", sub {
    my $WP_CONF = get (cmdb "wp_config");
    Rex::Module::CMS::WP_CLI::setup();
    # Set default base_dir
    set wp_cli => base_dir => "/var/www/website.com";

    Rex::CMS::WP_CLI::Core::install({conf => $WP_CONF);
 };
 ```


Or, you can use it as a library in your project
```
 use Rex::Module::CMS::WP_CLI;
 use Rex::Module::CMS::WP_CLI::Core;
    
 task "prepare", sub {
    Rex::Module::CMS::WP_CLI::setup();
    # Set default base_dir
    set wp_cli => base_dir => "/var/www/website.com";

    Rex::CMS::WP_CLI::Core::install({conf => {
            'WP_HOME' => 'http://www.acessolivre.pt',
            'WP_SITEURL' => 'http://www.website.com',
            'DB_NAME' => 'db_name'}, params => '--allow-root'});
 };
 ```