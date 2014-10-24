package stdouthandle;

#####################################################################
# DO NOT USE THIS MODULE DIRECTLLY, PLEASE USE WEBTOOLS INSTEAD,
# other else you may rase an error!!!
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################

require Exporter;
use Fcntl;
use vars qw($VERSION @ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(reset clear $var_printing_mode);
$VERSION = "1.10";
$var_printing_mode = 'buffered';
my $cnf = (-e './conf') ? './conf/' : '../conf/';
eval "use lib \'$cnf\';";
require 'config.pl';

sub TIEHANDLE
 {
  my $class = shift;
  $this_handle = bless({header => '', body => '', offset => 0}, $class);
  return ($this_handle);
 }

sub WRITE
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    my ($buf,$len,$ofs) = @_;
    my $sclr = '';
    $ofs = (($ofs eq '') or (!defined($ofs))) ? 0 : $ofs;
    if(defined($len)) { $sclr = substr($buf,$ofs,$len); }
    else { $sclr = substr($buf,$ofs); }
    my $i = length($sclr);
    $this->{'body'} .= $sclr;
    $webtools::print_flush_buffer .= $sclr;
    $this->{'offset'} += $i;
    return(1);
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::write($_[0],$_[1],$_[2]);
    select($oldHand);
   }
 }

sub PRINT
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   { 	
    my @data = @_;
    my $sclr = join('',@data);
    $this->{'body'} .= $sclr;
    $webtools::print_flush_buffer .= $sclr;
    $this->{'offset'} += length($sclr);
    return(1);
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::print(@_);
    select($oldHand);
   }
 }

sub PRINTF
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    my $frmt = shift;
    my $r = sprintf($frmt,@_);
    $this->{'body'} .= $r;
    $webtools::print_flush_buffer .= $r;
    $this->{'offset'} += length($r);
    return(1);
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::print(@_);
    select($oldHand);
   }
 }

sub READ
 {
  my $this = shift;
  my $buf = \$_[0];
  my (undef,$len,$ofs) = @_;
  if ($var_printing_mode eq 'buffered')
   {
    my $sclr = $this->{'body'};
    my $bufr = substr($sclr,$ofs);
    $$buf = $bufr;
    return(length($bufr));
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::read($buf,$len,$ofs);
    select($oldHand);
   }
}
 
sub READLINE
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    my $buf = '';
    my $sclr = $this->{'body'};
    if ($this->{'offset'} == -1) { return (undef); }
    $buf = substr($sclr,$this->{'offset'});
    return($buf);
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::readline($_[0]);
    select($oldHand);
   }
 }
 
sub GETC
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    my $buf;
    my $sclr = $this->{'body'};
    if ($this->{'offset'} == -1) { return (undef); }
    $buf = substr($sclr,$this->{'offset'},1);
    return($buf);
   }
 else
   {
    local $oldHand = select(STDOUT);
    CORE::getc(@_);
    select($oldHand);
   }
 }
 
sub SEEK
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    my $where = shift;
    my $whence = shift;
    if($whence == SEEK_CUR) { $this->{'offset'} += $where; }
    if($whence == SEEK_SET) { $this->{'offset'} = $where; }
    if($whence == SEEK_END) { $this->{'offset'} = length($this->{'body'})+$where; }
    return(1);
   }
 else
   {
    local $oldHand = select(STDOUT);
    CORE::seek($_[0],$_[1],$_[2]);
    select($oldHand);
   }
 }

sub TELL
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    return ($this->{'offset'});
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::tell(@_);
    select($oldHand);
   }
 }
 
sub EOF
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    if(length($this->{'body'}) <= $this->{'offset'}) { return(1); }
    return(0);
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::eof(@_);
    select($oldHand);
   }
 }

sub BINMODE
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    return(1);
   }
 else
   {
    local $oldHand = select(STDOUT);
    CORE::binmode(@_);
    select($oldHand);
   }
 }

sub reset
 {
  my $this = shift;
  $this->{'offset'} = 0;
  return(1);
 }

sub clear
 {
  my $this = shift;
  $this->{'header'} = '';
  $this->{'body'} = '';
  $this->{'offset'} = 0;
  return(1);
 }

sub OPEN
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    my $filename = shift;
    $this->{'header'} = '';
    $this->{'body'} = '';
    $this->{'offset'} = 0;
    return(1);
   }
 else
   {
    local $oldHand = select(STDOUT);
    CORE::open(@_);
    select($oldHand);
   }
 }

sub CLOSE
 {
  my $this = shift;
  if ($var_printing_mode eq 'buffered')
   {
    eval {webtools::flush_print();};
    $this->{'header'} = '';
    $this->{'body'} = '';
    $this->{'offset'} = 0;
    return(1);
   }
  else
   {
    local $oldHand = select(STDOUT);
    CORE::close(@_);
    select($oldHand);
   }
 }

sub DESTROY
 {
  my $this = shift;
  eval {webtools::flush_print();};
  $this->{'header'} = '';
  $this->{'body'} = '';
  $this->{'offset'} = 0;
  return(1);
 }
 
1;
__END__

=head1 NAME

 stdouthandle.pm - STDOUT handle module used from webtools.pm

=head1 DESCRIPTION

=over 4

This module is used internal by WebTools module.

=item Specifications and examples

=back

 Please read HELP.doc and see all examples in docs/examples directory

=head1 AUTHOR

 Julian Lishev - Bulgaria,Sofia
 e-mail: julian@proscriptum.com

=cut