use utf8;
# ABSTRACT: Validation and utilities for Eircodes / Irish postcodes
package Eircode;

# Check Eircodes / Irish postcodes

=head1 SYNOPSIS

 use Eircode qw< check_eircode >;

 my $data = "not an eircode";

 if( ! check_eircode($data) ){
    die 'Invalid';
 }

=head1 DESCRIPTION

A module for checking Irish postcodes / Eircodes  / éirchód.


=head1 EXPORTABLE

=cut

use strict;
use Carp;
use Const::Fast;
use parent qw< Exporter >;

our @EXPORT_OK = ( qw<
                         check_eircode
                         normalise_eircode
                         split_eircode
                     > );
our $VERSION = "0.1.0";

=head2 check_eircode

 check_eircode("A65 B2CD") or die;

Checks it's first argument to see if it looks like a valid Eircode. If it does
it returns a truthy value, if not it returns a falsey value.

A second argument, a hashref, can be provided to tweak the validation, these
are all key => bool options.

 strict => 1, # enforces upper case and the space mutually exclusive with lax
 lax => 1, # allows any valid sequence irriguadless of spaces. mutually
           # exclusive with strict.

The default behaviour is to enforce the space but not case sensitivity.

So:

  check_eircode("a65 b2cd"); # pass
  check_eircode("a65b2cd", {lax => 1}); # pass
  check_eircode("a65b2cd"); # fail
  check_eircode("a65b2cd", {strict => 1}); # fail
  check_eircode("a65 b2cd", {strict => 1}); # fail
  check_eircode("A65 B2CD", {strict => 1}); # pass

=cut


sub check_eircode{
    my( $data, $opt, @x ) = @_;
    if( scalar @x ) {
        croak 'Usage check_eircode($data, {});';
    }

    $opt ||= {};

    my $strict = $opt->{strict};
    my $lax = $opt->{lax};

    if( $strict && $lax ){
        croak 'Cant be strict and lax at the same time';
    }

    if( $lax ){
        $data =~ tr/[ ]//d;
    }

    unless($strict){
        $data = uc($data);
    }

    $data or return;

    my $re = build_re($opt);
    if( $strict ){
        return $data =~ /$re/;
    }
    else{
        return $data =~ /$re/i;
    }

}

const my $EIR_LETTER => 'A-NP-Z';
const my $LETTER_CLASS => "[$EIR_LETTER]";
const my $EIR_ANY => "[$EIR_LETTER\\d]";
const my $ROUTING_KEY => "${LETTER_CLASS}${EIR_ANY}{2}";
const my $UID => "${EIR_ANY}{4}";

sub build_re{
    my($opt) = @_;
    my $lax = $opt->{lax};

    my $re;
    if( $lax ){
        $re = qr{^$ROUTING_KEY$UID$};
    }
    else{
        $re = qr{^$ROUTING_KEY\s+$UID$};
    }

}

=head2 normalise_eircode

  say normalise_eircode("a65b2cd"); # Outputs A65 B2CD

Takes a loosely formatted eircode and formats it in upper case with the
correct spacing. If the input doesn't look like a valid eircode will die with
"invalid eircode".

=cut
sub normalise_eircode{
    my($input) = @_;
    $input = uc $input;
    $input =~ tr/ \t//d;
    my($routing_key, $uid) = split_eircode($input);
    return "$routing_key $uid";
}

=head2 split_eircode

  my($routing_key, $uid) = split_eircode("a65 b2cd");
  my($routing_key, $uid) = split_eircode("a65b2cd");

Take an eircode and gives you the two constitieent parts, the routing key and
the uid. 

=cut

sub split_eircode{
    my($input) = @_;
    my( $routing_key, $uid ) = ($input =~ /^($ROUTING_KEY)\s*($UID)$/i);
    $routing_key && $uid or die 'invalid eircode';
    return ($routing_key, $uid);
}


=head1 VALIDATION NOTES

The validation doesn't check that the eircode is an existing code, merely that
the formatting is correct, doesn't contain invalid characters etc. If you want
to ensure the Eircode is a real existing code that goes well beyond the scope
of what this module is trying to achieve. However you probably still want to
run this kind of check before you go dialing out to an API to do that kind of
check. 


=head1 FUTURE

The checking is currently basic and there are no tools for dismembering an
Eircode into it's parts or other such utilities which would seem to be useful here.

=head1 REFERENCES

https://en.wikipedia.org/wiki/Postal_addresses_in_the_Republic_of_Ireland
https://www.eircode.ie/


=head1 CREDIT

Time to write this was provided by Print Evolved ltd, see
http://www.printevolved.co.uk for all your print / print technology needs.

=cut
;1
