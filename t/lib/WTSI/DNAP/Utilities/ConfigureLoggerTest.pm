package WTSI::DNAP::Utilities::ConfigureLoggerTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 9;
use Test::Exception;
use Log::Log4perl;
use Log::Log4perl::Level;
use File::Temp qw/tempdir/;
use Try::Tiny;

BEGIN { use_ok('WTSI::DNAP::Utilities::ConfigureLogger'); }

use WTSI::DNAP::Utilities::ConfigureLogger qw/log_init/;

our $DEFAULT_LOG4PERL_CONF = './etc/log4perl_tests.conf';

Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);

# Note: Calling Log::Log4perl->init will clobber any existing log config
# and substitute the new one. Where possible, tests are configured to write
# to the standard tests.log file in addition to custom logfiles.

sub init_from_config_file : Test(4) {

    # configure from log4perl config file
    my $log = Log::Log4perl->get_logger('main');
    my $tmp = tempdir('ConfigureLoggerTest_XXXXXX', CLEANUP => 1);
    my $log_path = $tmp."/init_from_config_file.log";
    my $embedded_conf = q(
        log4perl.logger.WTSI.DNAP.Utilities = TRACE, A1
        log4perl.appender.A1          = Log::Log4perl::Appender::File
        log4perl.appender.A1.layout   = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.A1.layout.ConversionPattern = %d %-5p %c %M - %m%n
        log4perl.appender.A1.filename = tests.log
        log4perl.appender.A1.utf8     = 1

        log4perl.logger.WTSI.DNAP.Utilities = INFO, A1
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
    close $out || $log->logcroak("Cannot close temporary logconf path '",
                                 $config_path, "': $!");
    try {
        ok(log_init($config_path), "Logging initialised with config path");
        my $log = Log::Log4perl->get_logger('main');
        my $info_string = "Testing output to custom log file, level INFO";
        $log->info($info_string);
        ok(-e $log_path, "Custom log file written");
        ok(system("grep '$info_string' $log_path") == 0, 'Info output found');

        my $debug_string = "Testing log debug output";
        $log->debug($debug_string);
        ok(system("grep '$debug_string' $log_path") != 0,
           'Debug output not found at info level');
    } catch {
        Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);
        my $log = Log::Log4perl->get_logger('main');
        $log->error("Error testing log config: $_");
    };
    # revert to default log config after success
    Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);
}

sub init_from_output_path : Test(4) {
    # configure with output file path
    my $tmp = tempdir('ConfigureLoggerTest_XXXXXX', CLEANUP => 1);
    my $log_path = $tmp."/init_from_output_path.log";
    my $levels = [$WARN, $INFO, ];
    try {
        # this try block *disables* logging to the default tests.log
        ok(log_init(undef, $log_path, $levels),
           "Logging initialised with output path");
        my $log = Log::Log4perl->get_logger('main');
        my $info_string = "Testing output to custom log file, level INFO";
        $log->info($info_string);
        ok(-e $log_path, "Custom log file written");
        ok(system("grep '$info_string' $log_path") == 0, 'Info output found');
        my $debug_string = "Testing log debug output";
        $log->debug($debug_string);
        ok(system("grep '$debug_string' $log_path") != 0,
           'Debug output not found at info level');
    } catch {
        Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);
        my $log = Log::Log4perl->get_logger('main');
        $log->error("Error testing log config: $_");
    };
    # revert to default log config after success
    Log::Log4perl::init($DEFAULT_LOG4PERL_CONF);
}

1;
