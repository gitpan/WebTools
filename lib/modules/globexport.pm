package globexport;
#####################################################################
#
#         Global Variable Exporter 
# This module read all variables from "form" into %formdatah - hash,
# @formdataa - array. And all variables from cookies.
# ALL THESE vars are placed over their respectiv GLOBAL vars!!!
# Example: $formdatah{'user'} is placed over global variable $user
#          Cookie var 'sid' is placed over global variable $sid
# Note: If there are vars with same names both into "form" and
#       into "cookie". The "cookie" var is placed over "form"
#       variable..so in this case "cookie" has higher 
#       Please see config.pl to change priority order.
# Example: If we have: $formdatah{'age'} and cookie var 'age', global
#          var $age will contain cookie's var value!
# Note: If cookie var "x" is not exist, then global var $x will has
#       "form's" var value (if exists :-)
# HINT: These vars are exacly like vars in Php language
# Note: Both POST and GET vars are fetch evry time!
#####################################################################
# DO NOT USE THIS MODULE DIRECTLLY, PLEASE USE WEBTOOLS INSTEAD,
# in any other case you may rase an error!!!
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################
require Exporter;

BEGIN {
use vars qw($VERSION @ISA @EXPORT);
    $VERSION = "1.004";
    @ISA = qw(Exporter);
    $askqwvar_locv = '%uploaded_files %uploaded_original_file_names %formdatah %Cookies @formdataa @multipart_headers $parsedform $globvars $contenttype $query';
    
 $query = '';
 $n = 0;
 $f_up = 0;
 $parsedform = 0;
 
 my $cnf = (-e './conf') ? './conf' : '../conf';
 eval "use lib \'$cnf\';";
 require 'config.pl';

 my $lib = (-e $library_path) ? $library_path : '.'.$library_path;
 my $drv = (-e $driver_path) ? $driver_path : '.'.$driver_path;
  
 use lib './';
 eval "use lib \'$lib\';";
 eval "use lib \'$drv\';";
 
 require 'cookie.pl';
 require 'cgi-lib.pl';
 
if(!$parsedform){
	
 my (%cgi_data,   # The form data
     %cgi_cfn,    # The uploaded file(s) client-provided name(s)
     %cgi_ct,     # The uploaded file(s) content-type(s).  These are
                  #   set by the user's browser and may be unreliable
     %cgi_sfn,    # The uploaded file(s) name(s) on the server (this machine)
     @cgi_ar,
     $ret,        # Return value of the ReadParse call.       
     $buf         # Buffer for data read from disk.
    );


 ReadParse(\%cgi_data,\%cgi_cfn,\%cgi_ct,\%cgi_sfn,\@cgi_ar);
 
 $contenttype = 'single';
 @formdataa = @cgi_ar;
 %formdatah = %cgi_data;
 %uploaded_original_file_names = %cgi_cfn;
 %uploaded_files = %cgi_sfn;
 $parsedform = 1;
 
 $askqwvar_bstr = '';
 $globvars = '';

 foreach $askqwvar_k ( keys(%formdatah))
  {
   my $askqwvar_v = $formdatah{$askqwvar_k};
   if(exists($formdatah{$askqwvar_k}))
     {
      if($askqwvar_k =~ m/^[A-Za-z0-9_]+$/so)
        {
         $askqwvar_bstr .= '$'.$askqwvar_k.' ';
         $askqwvar_v =~ s/\|/\\\|/sgo;
         $askqwvar_elval = '$'.$askqwvar_k.' = q|'.$askqwvar_v.'|;';
         $globvars .= $askqwvar_elval."\n";
         eval $askqwvar_elval;
        }
     }
  }
 } 

 my %sess_cookies = ();
 GetCookies();
 %sess_cookies = %Cookies;
 foreach my $askqwvar_l (keys %Cookies)
  {
      my ($askqwvar_n,$askqwvar_v) = ($askqwvar_l,$Cookies{$askqwvar_l});
      $askqwvar_n =~ s/ //sgo;
      if($askqwvar_n =~ m/^[A-Za-z0-9_]+$/so)
        {
         $askqwvar_v =~ s/\|/\\\|/sgo;
         if($cpg_priority eq 'cookie')
           {
            $askqwvar_bstr .= '$'.$askqwvar_n.' ';
            $askqwvar_elval = '$'.$askqwvar_n.' = q|'.$askqwvar_v.'|;';
            $globvars .= $askqwvar_elval."\n";
            eval $askqwvar_elval;
           }
         else
           {
            $sys_demo_var_value2 = 1;
            $sys_skqwvar_elval = '$sys_demo_var_value2 = defined($'.$askqwvar_n.') ? 1 : 0;';
            eval $sys_skqwvar_elval;
            if(!$sys_demo_var_value2)
              {
               $askqwvar_bstr .= '$'.$askqwvar_n.' ';
               $askqwvar_elval = '$'.$askqwvar_n.' = q|'.$askqwvar_v.'|;';
               $globvars .= $askqwvar_elval."\n";
               eval $askqwvar_elval;
              }
           }
        } 
  }
 
  $askqwvar_evexp = '@EXPORT = qw('."$askqwvar_bstr$askqwvar_locv);";
  eval $askqwvar_evexp;
}

1;
__END__

=head1 NAME

 globexport.pm - Global Exporter module used from webtools.pm

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