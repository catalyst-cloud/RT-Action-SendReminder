package RT::Action::SendReminder;
use base 'RT::Action';
use strict;
use warnings;

our $VERSION = 0.01;

=head1 NAME

RT::Action::SendReminder - Send a reminder, but don't update LastUpdated

=head1 DESCRIPTION

An Action which can be used from an external tool, or in any situation
where a ticket transaction has not been started, to send a reminder about
a ticket, but not change the LastUpdated value.

=head1 RT VERSION

Works with RT 4.4.x and above.

=head1 SYNOPSIS

    my $action_obj = RT::Action::SendReminder->new(
        'TicketObj'   => $ticket_obj,
        'TemplateObj' => $template_obj,
    );
    my $result = $action_obj->Prepare();
    $action_obj->Commit() if $result;

=head1 METHODS

=head2 Prepare

Check for the existence of a Transaction.  If a Transaction already
exists, and is of type "Comment" or "Correspond", abort because that
will give us a loop.

=cut


sub Prepare {
    my $self = shift;
    if (defined $self->{'TransactionObj'} &&
        $self->{'TransactionObj'}->Type =~ /^(Comment|Correspond)$/) {
        return undef;
    }
    return 1;
}

=head2 Commit

Create a Transaction by calling the ticket's Correspond method on our
parsed Template, which may have an RT-Send-Cc or RT-Send-Bcc header.
The Transaction will be of type Correspond.  This Transaction can then
be used by the scrips that actually send the email.

=cut

sub Commit {
    my $self = shift;
    $self->CreateTransaction();
}

sub CreateTransaction {
    my $self = shift;

    my $LastUpdated = $self->{'TicketObj'}->LastUpdated;

    my ($result, $msg) = $self->{'TemplateObj'}->Parse(
        TicketObj => $self->{'TicketObj'});
    return undef unless $result;

    my ($trans, $desc, $transaction) = $self->{'TicketObj'}->Correspond(
        MIMEObj => $self->TemplateObj->MIMEObj);
    $self->{'TransactionObj'} = $transaction;

    my ( $msg, $val ) = $self->{'TicketObj'}->__Set(
        Field => 'LastUpdated',
        Value => $LastUpdated
    );
}


RT::Base->_ImportOverlays();

=head1 AUTHOR

Andrew Ruthven, Catalyst Cloud Ltd E<lt>puck@catalystcloud.nzE<gt>

=for html <p>All bugs should be reported via email to <a
href="mailto:bug-RT-Action-SendReminder@rt.cpan.org">bug-RT-Action-SendReminder@rt.cpan.org</a>
or via the web at <a
href="http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Action-SendReminder">rt.cpan.org</a>.</p>

=for text

    All bugs should be reported via email to
        bug-RT-Action-SendReminder@rt.cpan.org
    or via the web at
        http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Action-SendReminder

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Catalyst Cloud Ltd
Portions of this code are based on RT::Action::RecordCorrespondence and are
Copyright (c) 1996-2016 Best Practical Solutions, LLC.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
