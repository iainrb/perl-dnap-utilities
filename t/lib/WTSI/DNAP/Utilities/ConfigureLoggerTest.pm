package WTSI::DNAP::Utilities::ConfigureLoggerTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 4;
use Test::Exception;
use Log::Log4perl;
use Log::Log4perl::Level;
use File::Temp qw/tempdir/;

BEGIN { use_ok('WTSI::DNAP::Utilities::ConfigureLogger'); }

use WTSI::DNAP::Utilities::ConfigureLogger qw/log_init/;

Log::Log4perl::init('./etc/log4perl_tests.conf');

my $log = Log::Log4perl->get_logger('main');

# Note: Calling Log::Log4perl->init will clobber any existing log config
# and substitute the new one. As a workaround, some tests are run by
# calling a command-line script.

my $log_script = './t/bin/test_log_config.pl';

sub init_from_config_file : Test(3) {

    # configure from log4perl config file
    my $tmp = tempdir('ConfigureLoggerTest_XXXXXX', CLEANUP => 1);
    my $log_path = $tmp."/init_from_config_file.log";
    my $embedded_conf = q(
        log4perl.logger               = INFO, A1
        log4perl.appender.A1          = Log::Log4perl::Appender::File
        log4perl.appender.A1.layout   = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.A1.layout.ConversionPattern = %d %-5p %c %M - %m%n
        log4perl.appender.A1.filename = ).$log_path.q(
        log4perl.appender.A1.utf8     = 1
    );

    my $config_path = $tmp."/log4perl.conf";
    open(my $out, '>', $config_path) ||
        $log->logcroak("Cannot open temporary logconf path '",
                       $config_path, "': $!");
    print $out $embedded_conf;
    close $out ||
        $log->logcroak("Cannot close temporary logconf path '",
                       $config_path, "': $!");

    my $cmd = "$log_script --config $config_path 2> /dev/null";
    ok(system($cmd)==0, "Command '$cmd' exit status OK");

    my $info_string = 'Testing log info output';
    ok(system("grep '$info_string' $log_path > /dev/null") == 0,
       'Info output found');

    my $debug_string = 'Testing log debug output';
    ok(system("grep '$debug_string' $log_path > /dev/null") != 0,
       'Debug output not found at info level');
}

# sub init_from_output_path : Test(4) {
#     # configure with output file path
#     my $tmp = tempdir('ConfigureLoggerTest_XXXXXX', CLEANUP => 1);
#     my $log_path = $tmp."/init_from_output_path.log";
#     my $levels = [$WARN, $INFO, ];
#     try {
#         # this try block *disables* logging to the default tests.log
#         ok(log_init(undef, $log_path, $levels),
#            "Logging initialised with output path");
#         my $log = Log::Log4perl->get_logger('main');
#         my $info_string = "Testing output to custom log file, level INFO";
#         do {
#             # suppress log message to STDERR
#             local *STDERR;
#             open (STDERR, '>>', '/dev/null');
#             $log->info($info_string);
#         };
#         ok(-e $log_path, "Custom log file written");
#         ok(system("grep '$info_string' $log_path > /dev/null") == 0,
#            'Info output found');
#         my $debug_string = "Testing log debug output";
#         $log->debug($debug_string);
#         ok(system("grep '$debug_string' $log_path > /dev/null") != 0,
#            'Debug output not found at info level');
#     } catch {
#      #   Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);
#       #  my $log = Log::Log4perl->get_logger('main');
#        # $log->error("Error testing log config: $_");
#     };
#     # revert to default log config after success
#     #Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);
# }

1;
