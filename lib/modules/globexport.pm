package globexport;
#####################################################################
#
#         Global Variable Exporter 
# This module read all variables from "form" into %formdatah - hash,
# @formdataa - array. And all variables from cookies.
# ALL THESE vars are placed over their respective GLOBAL vars!!!
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
    $VERSION = "1.23";
    @ISA = qw(Exporter);
    $sys_askqwvar_locv = '%uploaded_files %uploaded_original_file_names %formdatah %Cookies @formdataa '.
                         '%global_hashes @multipart_headers $parsedform $sys_globvars $contenttype $query';
    
 $query = '';
 $n = 0;
 $f_up = 0;
 $parsedform = 0;
 
 my $cnf = (-e './conf') ? './conf' : '../conf';
 eval "use lib \'$cnf\';";
 if($webtools::sys_config_pl_loaded ne 1) {require 'config.pl';}

 my $lib = (-e $webtools::library_path) ? $webtools::library_path : '.'.$webtools::library_path;
 my $drv = (-e $webtools::driver_path) ? $webtools::driver_path : '.'.$webtools::driver_path;
  
 use lib './';
 eval "use lib \'$lib\';";
 eval "use lib \'$drv\';";
 
 if($webtools::run_restrict_mode =~ m/^on$/si)
  {
   eval "require 'allowed.pl';";
   if($@ eq '')
     {
      if(!Check_Remote_IP($ENV{'REMOTE_ADDR'}))
        {
         print "Content-type: text/html\n\n";
         print "<H3><BR><B>You are <font color='red'>not allowed</font> to see that information, due current <font color='red'>restriction policy</font> for your host!<BR><BR>IP: ".$ENV{'REMOTE_ADDR'}."</B></H3>";
         exit();    # Exit because IP restriction!
        }
     }
   }
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
 
 %sys_ported_hashes = ();
 %global_hashes = ();
 $sys_askqwvar_bstr = '';
 $sys_globvars = '';

 foreach $sys_askqwvar_k ( keys(%formdatah))
  {
   my $sys_askqwvar_v = $formdatah{$sys_askqwvar_k};
   if(exists($formdatah{$sys_askqwvar_k}))
     {
      if($sys_askqwvar_k =~ m/^[A-Za-z0-9_]+$/so)
        {
         if(!($sys_askqwvar_k =~ m/^sys\_/si))
          {
           if(!(eval 'defined($webtools::'.$sys_askqwvar_k.') ? 1 : 0;'))
            {
             $sys_askqwvar_bstr .= '$'.$sys_askqwvar_k.' ';
             $sys_askqwvar_elval = '$'.$sys_askqwvar_k.' = $sys_askqwvar_v;';
             $sys_globvars .= $sys_askqwvar_elval."\n";
             eval $sys_askqwvar_elval;
            }
          }
        }
     }
   if($sys_askqwvar_k =~ m/^\%inputhash\_([A-Z0-9]+?)\_([A-Z0-9_]+)$/sio)
     {
      my $sys_askqwvar_L_hn = $1;
      my $sys_askqwvar_L_vn = $2;
      
      $sys_askqwvar_elval = '$inputhash_'.$sys_askqwvar_L_hn.'{'.$sys_askqwvar_L_vn.'} = $sys_askqwvar_v;';
      $sys_globvars .= $sys_askqwvar_elval."\n";
      eval $sys_askqwvar_elval;
      
      if(!exists($sys_ported_hashes{$sys_askqwvar_L_hn}))
       {
        $sys_askqwvar_bstr .= '%inputhash_'.$sys_askqwvar_L_hn.' ';
        $sys_ported_hashes{$sys_askqwvar_L_hn} = 1;
       }
     }
  }
 } 
 my $sys_keys;
 foreach $sys_keys (keys %sys_ported_hashes)
  {
   $sys_keys =~ s/^\%(.*)$/$1/si;
   my $sys_keys_h = 'inputhash_'.$sys_keys;
   eval '$global_hashes{$sys_keys_h} = \%inputhash_'.$sys_keys.';';
  }
 my %sess_cookies = ();
 GetCookies();
 %sess_cookies = %Cookies;
 my $sys_askqwvar_l;
 foreach $sys_askqwvar_l (keys %Cookies)
  {
      my ($sys_askqwvar_n,$sys_askqwvar_v) = ($sys_askqwvar_l,$Cookies{$sys_askqwvar_l});
      $sys_askqwvar_n =~ s/ //sgo;
      if($sys_askqwvar_n =~ m/^[A-Za-z0-9_]+$/so)
        {
         if(!($sys_askqwvar_n =~ m/^sys\_/si))
          {
           if($webtools::cpg_priority eq 'cookie')
             {
              if(!(eval 'defined($webtools::'.$sys_askqwvar_n.') ? 1 : 0;'))
               {
                $sys_askqwvar_bstr .= '$'.$sys_askqwvar_n.' ';
                $sys_askqwvar_elval = '$'.$sys_askqwvar_n.' = $sys_askqwvar_v;';
                $sys_globvars .= $sys_askqwvar_elval."\n";
                eval $sys_askqwvar_elval;
               }
             }
           else
             {
              $sys_demo_var_value2 = 1;
              $sys_skqwvar_elval = '$sys_demo_var_value2 = defined($'.$sys_askqwvar_n.') ? 1 : 0;';
              eval $sys_skqwvar_elval;
              if(!$sys_demo_var_value2)
                {
                 if(!(eval 'defined($webtools::'.$sys_askqwvar_n.') ? 1 : 0;'))
                  {
                   $sys_askqwvar_bstr .= '$'.$sys_askqwvar_n.' ';
                   $sys_askqwvar_elval = '$'.$sys_askqwvar_n.' = $sys_askqwvar_v;';
                   $sys_globvars .= $sys_askqwvar_elval."\n";
                   eval $sys_askqwvar_elval;
                  }
                }
             }
          }
        } 
  }
 
  $sys_askqwvar_evexp = '@EXPORT = qw('."$sys_askqwvar_bstr$sys_askqwvar_locv);";
  eval $sys_askqwvar_evexp;
  
  # Clear vars
  my $sys_keys;
  my @sys_delete = ();
  foreach $sys_keys (%formdatah)
   {
    if($sys_keys =~ m/^\%(.*)$/si)
     {
      push(@sys_delete,$sys_keys);
     }
   }
  foreach $sys_keys (@sys_delete)
   {
    delete $formdatah{$sys_keys};
   }
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