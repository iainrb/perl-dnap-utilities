package WTSI::DNAP::Utilities::Loggable;

use strict;
use warnings;
use Log::Log4perl;
use Moose::Role;

our $VERSION = '';

# This is used if Log:Log4perl has not been initialised elsewhere when
# this Role is used.
my $default_conf = << 'EOF';
log4perl.logger = WARN, A1

log4perl.appender.A1           = Log::Log4perl::Appender::Screen
log4perl.appender.A1.utf8      = 1
log4perl.appender.A1.layout    = Log::Log4perl::Layout::PatternLayout
log4perl.appender.A1.layout.ConversionPattern = %d %p %m %n
EOF

# These methods are autodelegated to instances with this role.
our @HANDLED_LOG_METHODS = qw(trace debug info warn error fatal
                              logwarn logdie
                              logcarp logcluck logconfess logcroak);

has 'logger' => (is      => 'rw',
                 isa     => 'Log::Log4perl::Logger',
                 handles => [@HANDLED_LOG_METHODS],
                 default => sub {
                    Log::Log4perl->init_once(\$default_conf);
                    return Log::Log4perl->get_logger(q[]);
                  });

no Moose;

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::Loggable

=head1 DESCRIPTION

Provides a logging facility via Log::Log4perl. When consumed, this
role automatically delegates Log::Log4perl logging method calls to a
logger. If no logger is condigured a default will be created where the
root logger is configured to WARN to STDERR.

=head1 AUTHOR

Keith James <kdj@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2013, 2014, 2016 Genome Research Limited. All Rights
Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
