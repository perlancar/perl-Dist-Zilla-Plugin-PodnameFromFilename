package Dist::Zilla::Plugin::PodnameFromFilename;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
use namespace::autoclean;

with (
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [':ExecFiles'],
    },
);

sub munge_files {
    my $self = shift;
    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
    my ($self, $file) = @_;
    my $content = $file->content;

    unless ($content =~ m{^#[ \t]*PODNAME:[ \t]*([^\n]*)[ \t]*$}m) {
        $self->log_debug(["skipping %s: no # PODNAME directive found", $file->name]);
        return;
    }

    my $podname = $1;
    if ($podname =~ /\S/) {
        $self->log_debug(["skipping %s: # PODNAME already filled (%s)", $file->name, $podname]);
        return;
    }

    ($podname = $file->name) =~ s!.+/!!;

    $content =~ s{^#\s*PODNAME:.*}{# PODNAME: $podname}m
        or die "Can't insert podname for " . $file->name;
    $self->log(["inserting podname for %s (%s)", $file->name, $podname]);
    $file->content($content);
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Fill out # PODNAME from filename

=for Pod::Coverage .+

=head1 SYNOPSIS

In C<dist.ini>:

 [PodnameFromFilename]

In your module/script:

 # PODNAME:

During build, PODNAME will be filled from filename. If Abstract is already
filled, will leave it alone.


=head1 DESCRIPTION

It's yet another DRY plugin. It's annoying that in scripts like
C<bin/some-progname> you have to specify:

 # PODNAME: some-progname

With this plugin, the value of PODNAME directive will be filled from filename.


=head1 SEE ALSO

L<https://github.com/rjbs/Dist-Zilla/issues/396>

