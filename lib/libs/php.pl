#####################################################################
# Broad library of base Php functions ported
# to Perl sub system: WebTools
# WARNING: NOT ALL OF FUNCTIONS WILL WORK AS YOU EXPECT!
#          That is related to particulrity of Perl language!
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################

# Implemented Set Of Functions

# $bool_result = IsSet(variable);
sub IsSet ($)
{
 if(shift(@_) ne undef) {return(1);}
 return(0);
}

# $bool_result = IsEmpty($scalar);
sub IsEmpty ($)
{
 my $fp = shift(@_);
 if(($fp eq undef) or ($fp eq '')) {return(1);}
 return(0);
}

# $type = gettype(variable);
sub gettype
{
 my ($fp_s) = @_;
 my @fp_a = @_;
 if($#fp_a == 0)
  {
   if(!IsSet($fp_s))  {return('EMPTY');}
   if(IsEmpty($fp_s)) {return('EMPTY');}
   if($fp_s =~ m/^(\+|\-)?([0-9])+$/s) {return('INT');}
   if($fp_s =~ m/^(\+|\-)?([0-9])*?(\.|\,)([0-9])+$/s) {return('FLOAT');}
   if(length(ref($fp_s))) {return('REF:'.ref($fp_s))};
   return('SCALAR');
  }
 else {return('LIST');}
}

# $bool_result = is_int(variable);
sub is_int
{
 my ($fp_s) = @_;
 if(gettype($fp_s) eq 'INT') {return(1);}
 return(0);
}

# $bool_result = is_integer(variable);
sub is_integer
{
 return(is_int(shift(@_)));
}

# $bool_result = is_long(variable);
sub is_long
{
 return(is_int(shift(@_)));
}

# $bool_result = is_float(variable);
sub is_float
{
 my ($fp_s) = @_;
 if(gettype($fp_s) eq 'FLOAT') {return(1);}
 return(0);
}

# $bool_result = is_double(variable);
sub is_double
{
 return(is_float(shift(@_)));
}

# $bool_result = is_real(variable);
sub is_real
{
 return(is_float(shift(@_)));
}

# $bool_result = is_string(variable);
sub is_string
{
 my ($fp_s) = @_;
 if(gettype($fp_s) eq 'SCALAR') {return(1);}
 return(0);
}

# $bool_result = is_ref(variable);
sub is_ref
{
 my ($fp_s) = @_;
 if(gettype($fp_s) =~ m/^REF\:/s) {return(1);}
 return(0);
}

# $new_value = settype($var,$type);
sub settype ($$)
{
 my ($fp_s,$type) = @_;
 
 if(($type =~ m/^int$/si) or ($type =~ m/^integer$/si))
  {
   $fp_s =~ s/ //g;
   $fp_s =~ s/\,/\./g;
   $fp_s =~ s/[^0-9\-\+\.]//g;
   return(int($fp_s));
  }
 if(($type =~ m/^double$/si) or ($type =~ m/^real$/si) or ($type =~ m/^float$/si))
  {
   $fp_s =~ s/ //g;
   $fp_s =~ s/\,/\./g;
   $fp_s =~ s/[^0-9\.\-\+]//g;
   return($fp_s + 0.0);
  }
 if(($type =~ m/^string$/si) or ($type =~ m/^str$/si))
  {
   return($fp_s.'');
  }
 if(($type =~ m/^bool$/si) or ($type =~ m/^boolean$/si))
  {
   if(($fp_s ne undef) and ($fp_s ne 0) and (length($fp_s) > 0)) {return(1);}
   return(0);
  }
 return($fp_s);
}

# $new_value = integer($var);
sub integer ($)
{
 my ($fp_s) = @_;
 $fp_s = settype($fp_s,'int');
 return($fp_s);
}

# $new_value = double($var);
sub double ($)
{
 my ($fp_s) = @_;
 $fp_s = settype($fp_s,'double');
 return($fp_s);
}

# $new_value = real($var);
sub real ($)
{
 my ($fp_s) = @_;
 $fp_s = settype($fp_s,'double');
 return($fp_s);
}

# $new_value = float($var);
sub float ($)
{
 my ($fp_s) = @_;
 $fp_s = settype($fp_s,'double');
 return($fp_s);
}

# $new_value = string($var);
sub string ($)
{
 my ($fp_s) = @_;
 $fp_s = settype($fp_s,'string');
 return($fp_s);
}

# $new_value = ceil ($double);
sub ceil ($)
{
 my ($fp_s) = @_;
 $fp_s = double($fp_s);
 return(int($fp_s + 0.5));
}

# $new_value = round ($double);
sub round ($)
{
 my ($fp_s) = @_;
 $fp_s = double($fp_s);
 return(int($fp_s + 0.5));
}

# $new_value = floor ($double);
sub floor ($)
{
 my ($fp_s) = @_;
 $fp_s = double($fp_s);
 return(int($fp_s - 0.5));
}

# $new_value = trunc ($double);
sub trunc ($)
{
 my ($fp_s) = @_;
 $fp_s = double($fp_s);
 return(int($fp_s));
}

# $ret = echo (...);
sub echo
{
 return(print(@_));
}

# $string = addslashes ($str);
sub addslashes
{
 my ($fp_s) = @_;
 $fp_s =~ s/\\/\\\\/sg;
 $fp_s =~ s/\'/\\\'/sg;
 $fp_s =~ s/\"/\\\"/sg;
 $fp_s =~ s/\x0/\\\x0/sg;
 return($fp_s);
}

# $string = bin2hex ($str);
sub bin2hex
{
 my $str = shift;
 $str =~ s/(.)/uc sprintf("%02x",ord($1))/seg;
 return $str
}

# $string = htmlspecialchars ($str);
sub htmlspecialchars 
{
 my $str = shift;
 $str =~ s{&}{&amp;}gso;
 $str =~ s{\"}{&quot;}gso;
 $str =~ s{<}{&lt;}gso;
 $str =~ s{>}{&gt;}gso;
 return $str;
}

# $string = trim ($str);
sub trim
{
 my $str = shift(@_);
 $str =~ s/^\ *//s;
 $str =~ s/\ *$//s;
 return($str);
}

# $string = ltrim ($str);
sub ltrim
{
 my $str = shift(@_);
 $str =~ s/^\ *//s;
 return($str);
}

# $string = rtrim ($str);
sub rtrim
{
 my $str = shift(@_);
 $str =~ s/\ *$//s;
 return($str);
}

# $length = strlen ($str);
sub strlen
{
 return(length(shift(@_)));
}

# $pos = strpos (...);
sub strpos
{
 return(index($_[0],$_[1],$_[2]));
}

# $str = wordwrap ($str,$width,$brk,$cut);
sub wordwrap
{
 my ($str,$width,$brk,$cut) = @_;
 my ($l,$clen,$res);
 return($str) if($str eq '');
 
 if($cut != 0 and $cut != 1) {$cut = 0;}
 if($width eq 0 or $width eq '') {$width = 75;}
 $brk = $brk || "\n";

 $clen = 0;
 $res = '';
 if($cut)
  {
   while($str)
    {
     my $l = substr($str,0,$width,'');
     $res .= $l.$brk;
    }
  }
 else
  {
   my @data = split(/\ /,$str);
   foreach $l (@data)
    {
     if(($clen + length($l)+1) > $width)
       {
        if($clen == 0)
          {
           $res .= $l." ";
          }
        else
          {
           $res .= $brk.$l." ";
          }
        $clen=(length($l)+1);
       }
     else 
       {
        $res .= $l." ";
        $clen += (length($l)+1);
       }
    }  
  }
 return($res);
}

# @mail_addrs = mx_lookup($domain,[path_to_nslookup]);
sub mx_lookup
{
 eval {use Socket;};
 my $result;
 my $domain = shift;
 my @digout;
 my $line;
 my @mxrecs = ();
 my $nslookup = $_[0] ne '' ? shift(@_) : 'nslookup';
 my $qrt = $domain;
 $qrt =~ s/\./\\\./sig;
 $nslookup .= " -q=MX $domain";
 @digout =  `$nslookup`;
 foreach $line (@digout) 
  {
   if($line =~ m/^$qrt\x9(MX)?\ ?preference\ =\ (\d{1,5})\, mail\ exchanger\ =\ (.*?)$/si)
    {
     my $h = $3;
     my $prority = $2;
     if ($h =~ m/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/s)
       {
        $h = $1;
        push(@mxrecs,$prority."\t".$h);
       }
     else
       {
        $h =~ s/\.$//s;
        $h =~ s/^[\ \t\r\n]*//s;
        $h =~ s/[\ \t\r\n]*$//s;
        (undef, undef, undef, undef, @addrs) = gethostbyname($h);
        $h  = inet_ntoa($addrs[0]);
        push(@mxrecs,$prority."\t".$h);
       }
    }
 }
 return sort(@mxrecs);
}

# TODO: More and more... :-)
$webtools::loaded_functions = $webtools::loaded_functions | 512;
1;