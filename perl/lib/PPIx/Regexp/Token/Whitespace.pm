=head1 NAME

PPIx::Regexp::Token::Whitespace - Represent whitespace

=head1 SYNOPSIS

 use PPIx::Regexp::Dumper;
 PPIx::Regexp::Dumper->new( 'qr{ foo }smx' )
     ->print();

=head1 INHERITANCE

C<PPIx::Regexp::Token::Whitespace> is a
L<PPIx::Regexp::Token|PPIx::Regexp::Token>.

C<PPIx::Regexp::Token::Whitespace> has no descendants.

=head1 DESCRIPTION

This class represents whitespace. It will appear inside the regular
expression only if the /x modifier is present, but it may also appear
between the type and the opening delimiter (e.g. C<qr {foo}>) or after
the regular expression in a bracketed substitution (e.g. C<s{foo}
{bar}>).

=head1 METHODS

This class provides no public methods beyond those provided by its
superclass.

=cut

package PPIx::Regexp::Token::Whitespace;

use strict;
use warnings;

use base qw{ PPIx::Regexp::Token };

use PPIx::Regexp::Constant qw{ COOKIE_REGEX_SET MINIMUM_PERL };

our $VERSION = '0.042_02';

sub perl_version_introduced {
    my ( $self ) = @_;
    return $self->{perl_version_introduced};
}

sub significant {
    return;
}

sub whitespace {
    return 1;
}

# Return true if the token can be quantified, and false otherwise
sub can_be_quantified { return };

# Objects of this class are generated either by the tokenizer itself
# (when scanning for delimiters) or by PPIx::Regexp::Token::Literal (if
# it hits a match for \s and finds the regular expression has the /x
# modifier asserted.

=begin comment

sub __PPIX_TOKENIZER__regexp {
    my ( $class, $tokenizer, $character ) = @_;

    return scalar $tokenizer->find_regexp( qr{ \A \s+ }smx );

}

=end comment

=cut

sub __PPIX_TOKEN__post_make {
    my ( $self, $tokenizer, $arg ) = @_;

    $self->{perl_version_introduced} = MINIMUM_PERL;

    # RT #91798.
    # TODO the above needs to be replaced by the following (suitably
    # modified) when the non-ASCII white space characters are finally
    # recognized by Perl.

=begin comment

    if ( ord $self->content() < 128 ) {
	$self->{perl_version_introduced} = MINIMUM_PERL;
    } elsif ( $tokenizer && $tokenizer->cookie( COOKIE_REGEX_SET ) ) {
	$self->{perl_version_introduced} = '5.017008';
    } else {
	$self->{perl_version_introduced} = '5.017009';
    }

=end comment

=cut

    # The extended white space characters came back in Perl 5.21.1

    $self->{perl_version_introduced} =
	( grep { 127 < ord } split qr{}, $self->content() )
	? '5.021001'
	: MINIMUM_PERL;

    return;
}

1;

__END__

=head1 SUPPORT

Support is by the author. Please file bug reports at
L<http://rt.cpan.org>, or in electronic mail to the author.

=head1 AUTHOR

Thomas R. Wyant, III F<wyant at cpan dot org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2015 by Thomas R. Wyant, III

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.0. For more details, see the full text
of the licenses in the directory LICENSES.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# ex: set textwidth=72 :
