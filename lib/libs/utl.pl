##############################################################
# Util library
##############################################################
# Modified by Julian Lishev 2001
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################
##############################################################
# Original author:
# This library (CGI::Util) was originaly written by:
# Copyright 1995-1997, Lincoln D. Stein. 
# All rights reserved. It may be used and modified freely,
# but I do request that this copyright notice remain attached
# to the file. You may modify this module as you wish, but if
# you redistribute a modified version, please attach a note 
# listing the modifications you have made.
##############################################################

$utl_escape_factor = "\t" ne "\011";
if ($utl_escape_factor) {
@utl_char_table = (
0,  1,  2,  3,  55, 45, 46, 47, 22, 5,  21, 11, 12, 13, 14, 15,
16, 17, 18, 19, 60, 61, 50, 38, 24, 25, 63, 39, 28, 29, 30, 31,
64, 90, 127,123,91, 108,80, 125,77, 93, 92, 78, 107,96, 75, 97,
240,241,242,243,244,245,246,247,248,249,122,94, 76, 126,110,111,
124,193,194,195,196,197,198,199,200,201,209,210,211,212,213,214,
215,216,217,226,227,228,229,230,231,232,233,173,224,189,95, 109,
121,129,130,131,132,133,134,135,136,137,145,146,147,148,149,150,
151,152,153,162,163,164,165,166,167,168,169,192,79, 208,161,7,
32, 33, 34, 35, 36, 37, 6,  23, 40, 41, 42, 43, 44, 9,  10, 27,
48, 49, 26, 51, 52, 53, 54, 8,  56, 57, 58, 59, 4,  20, 62, 255,
65, 170,74, 177,159,178,106,181,187,180,154,138,176,202,175,188,
144,143,234,250,190,160,182,179,157,218,155,139,183,184,185,171,
100,101,98, 102,99, 103,158,104,116,113,114,115,120,117,118,119,
172,105,237,238,235,239,236,191,128,253,254,251,252,186,174,89,
68, 69, 66, 70, 67, 71, 156,72, 84, 81, 82, 83, 88, 85, 86, 87,
140,73, 205,206,203,207,204,225,112,221,222,219,220,141,142,223);
}
# unescape html tags
sub htmlspecialchars {
  my $str = shift;
  $str =~ s{&}{&amp;}gso;
  $str =~ s{\"}{&quot;}gso;
  $str =~ s{<}{&lt;}gso;
  $str =~ s{>}{&gt;}gso;
  return $str;
}

# unescape MIME-encoded data
sub MIME_decoded_data {
  my $str = shift;
  return undef unless defined($str);
  $str =~ tr/+/ /;       # pluses become spaces
    if ($utl_escape_factor) {
      $str =~ s/%([0-9a-fA-F]{2})/chr $utl_char_table[hex($1)]/ge;
    } else {
      $str =~ s/%([0-9a-fA-F]{2})/chr hex($1)/ge;
    }
  return $str;
}

# MIME_coding_data 
sub MIME_encoding_data {
  my $str = shift;
  return undef unless defined($str);
  $str =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/seg;
  $str =~ s/\%20/\+/sg;
  return $str;
}

# makes date for cookies and HTTP headers
# expires (TIME,[cookie|http])
sub expires {
    my($time,$format) = @_;
    $format ||= 'http';

    my(@MON)=qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
    my(@WDAY) = qw/Sun Mon Tue Wed Thu Fri Sat/;

    # pass through preformatted dates for the sake of expire_calc()
    $time = expire_calc($time);
    return $time unless $time =~ /^\d+$/;

    # make HTTP/cookie date string from GMT'ed time
    # (cookies use '-' as date separator, HTTP uses ' ')
    my($sc) = ' ';
    $sc = '-' if $format eq "cookie";
    my($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime($time);
    $year += 1900;
    return sprintf("%s, %02d$sc%s$sc%04d %02d:%02d:%02d GMT",
                   $WDAY[$wday],$mday,$MON[$mon],$year,$hour,$min,$sec);
}

# This routine creates an expires time.
# expires_calc (TIME),
# where TIME is in format: [+|-]NUMBER[s|m|h|M|y] or just "now"
# example: expires_calc (+10h);   # Expired after 10 hours
sub expire_calc {
    my($time) = @_;
    my(%mult) = ('s'=>1,
                 'm'=>60,
                 'h'=>60*60,
                 'd'=>60*60*24,
                 'M'=>60*60*24*30,
                 'y'=>60*60*24*365);
    
    my($offset);
    if (!$time || (lc($time) eq 'now')) {
        $offset = 0;
    } elsif ($time=~/^\d+/) {
        return $time;
    } elsif ($time=~/^([+-]?(?:\d+|\d*\.\d*))([mhdMy]?)/) {
        $offset = ($mult{$2} || 1)*$1;
    } else {
        return $time;
    }
    return (time+$offset);
}

1;