#!/usr/bin/perl

use strict;
use warnings;

### after: use lib qw(@RT_LIB_PATH@);
use lib qw(/opt/rt3/local/lib /opt/rt3/lib);

my $config;
BEGIN {
$config = <<END;
Set(\@Plugins, 'RT::Extension::StatusSchemas');

Set(\%StatusSchemaMeta,
    default => {
        initial  => ['new'],
        active   => [qw(open stalled)],
        inactive => [qw(resolved rejected deleted)],
        transitions => {
            new      => [qw(open resolved rejected deleted)],
            open     => [qw(stalled resolved rejected deleted)],
            stalled  => [qw(open)],
            resolved => [qw(open)],
            rejected => [qw(open)],
            deleted  => [qw(open)],
        },
        actions => {
            'new -> open'     => ['Open It', 'Respond'],
            'new -> resolved' => ['Resolve', 'Comment'],
            'new -> rejected' => ['Reject',  'Respond'],
            'new -> deleted'  => ['Delete',  ''],

            'open -> stalled'  => ['Stall',   'Comment'],
            'open -> resolved' => ['Resolve', 'Comment'],
            'open -> rejected' => ['Reject',  'Respond'],
            'open -> deleted'  => ['Delete',  'hide'],

            'stalled -> open'  => ['Open It',  ''],
            'resolved -> open' => ['Re-open',  'Comment'],
            'rejected -> open' => ['Re-open',  'Comment'],
            'deleted -> open'  => ['Undelete', ''],
        },
    },
    delivery => {
        initial  => ['ordered'],
        active   => ['on way', 'delayed'],
        inactive => ['delivered'],
        transitions => {
            ordered   => ['on way', 'delayed'],
            'on way'  => ['delivered'],
            delayed   => ['on way'],
            delivered => [],
        },
        actions => {
            'ordered -> on way'   => ['Put On Way', 'Respond'],
            'ordered -> delayed'  => ['Delay',      'Respond'],

            'on way -> delivered' => ['Done',       'Respond'],
            'delayed -> on way'   => ['Put On Way', 'Respond'],
        },
    },
);
Set(\%StatusSchemas, delivery => 'delivery');
END
}

use RT::Test config => $config;

1;