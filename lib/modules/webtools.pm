package webtools;
####################################################
# Perl`s WEB module
####################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.
 
 require Exporter;
 use globexport;
 use stdouthandle;
###########################################
# BEGIN Section start here
###########################################
BEGIN {
use vars qw($VERSION $INTERNALVERSION @ISA @EXPORT);
    $VERSION = "1.11";
    $INTERNALVERSION = "1";
    @ISA = qw(Exporter);
    @EXPORT = 
     qw(
        $sess_cpg %sess_cookies %SESREG 
        session_start session_destroy session_register 
        $session_started session_clear_expired session_id 
        read_scalar read_array read_hash register_var unregister_var exists_var 
        session_id_adder href_sid_adder action_sid_adder 
        new_session session_expire_update update_var 
        session_set_id_name session_id_name session_ip_restrict 
        session_expiration session_cookie_path 
        convert_ses_time GetCurrentSID 
        
        GetCookies SetCookies  SetCookieExpDate SetCookiePath SetCookieDomain SetSecureCookie 
        GetCompressedCookies SetCompressedCookies delete_cookie write_cookie read_cookie 
        $cookie_path_cgi $cookie_domain_cgi $cookie_exp_date_cgi $secure_cookie_cgi 
        
        SignUpUser SignInUser 
        
        sql_query sql_fetchrow sql_affected_rows sql_inserted_id hideerror sql_select_db 
        sql_num_rows sql_quote sql_connect sql_disconnect $sql_host $sql_user test_connect 
        sql_data_seek sql_errmsg sql_errno $sql_pass $sql_database_sessions 
        $sql_sessions_table DB_OnDestroy DB_OnExit $system_database_handle 
        
        Header read_form read_form_array read_var href_adder action_adder 
        attach_var disattach_var 
        encode_separator decode_separator 
        StartUpInit RunScript set_script_timeout flush_print set_printing_mode DestroyScript 
        ClearBuffer ClearHeader $print_header_buffer $print_flush_buffer 
        r_str rand_srand b_print LoadCfgFile Parse_Form 
        *SESSIONSTDOUT $reg_buffer $print_header_buffer $print_flush_buffer 
        $sentcontent $apacheshtdocs %SIGNALS $loaded_functions 
       );

 #################################
 # PLEASE DO NOT MODIFY ANYTHING!
 # Please see file config.pl !!!
 #################################
 $| = 1;                     # Flush imediatly!   
 $sentcontent = 0;           # Show whether Send_Content() where called!
 $session_started = 0;       # Show whether session_start were started!
 %attached_vars = ();        # The variables that we will store
 $reg_buffer = '';           # Contain register session file!
 %SESREG = ();
 %SESREG_VAR = ();
 $print_flush_buffer = '';
 $print_header_buffer = '';
 $new_session_were_started = 0; # Default we are in old session!
 $sess_header_flushed = 0;      # Header Is not still flushed!
 $cookie_path_cgi = '/';
 $secure_cookie_cgi = '0';
 %SIGNALS = ();
 $flag_onFlush_Event = 0;
 $syspre_process_counter = 0;
 
 tie(*SESSIONSTDOUT,'stdouthandle');
 select(SESSIONSTDOUT);

 ################################################################
 # Needed definitions
 ################################################################
 my $local_sess_id = ''; # This is current session ID!!!
 @l_charset = ('085wOxVz1S','lZXa6M9RTk','FbHQvcjdmP','dQPpgALNqE','YDJ7CNG3yi',
               'mzk5l2F0xs','ThQPjd2OfR','G3YJK7IeWC','b4Zmol8SuM','jd9XvcHQa6',
               'sjyiDd21rB','RThpFALgNq');
 ################################################################
 $id = $ENV{HTTP_COOKIE} || $ENV{COOKIE};
  my @cookies = split(/;/s,$id);
  my $l;
  foreach $l (@cookies)
   {
    if($l ne '') 
      {
       my ($n,$v) = split(/=/s,$l);
       $n =~ s/ //sg;
       if (!exists($sess_cookies{$n}))
         {
          $sess_cookies{$n} = $v;
          }
      }
   }
  $Mysql::QUIET = $mysqlbequiet;

###########################################        
  $system_database_handle = undef;   # That is current opened DB Handler!
  $SIG{'TERM'} = \&On_Term_Event;
  $SIG{'STOP'} = \&On_Term_Event;
  $SIG{'PIPE'} = \&On_Term_Event;
  sub On_Term_Event
     {   # User hit STOP button or...admin shutdown Apache server :-)
  	if($system_database_handle ne undef)
  	  {
  	   my $q =<<'THAT_TERM_SIG_STR';
  	   if ($local_sess_id ne '')
  	     {
  	      close_session_file($system_database_handle);
  	     }
  	   DB_OnExit($system_database_handle);
  	   $system_database_handle = undef;
  	   $usystem_database_handle = undef;
           onExit();
THAT_TERM_SIG_STR
  	   eval $q;
  	  }
  	if(exists($webtools::SIGNALS{'OnTerm'}))
          {
           eval {
      	         my $OnEvent_code = $webtools::SIGNALS{'OnTerm'};
      	         &$OnEvent_code;
      	        };
          }
   CORE::exit;
  }
}

###########################################
# Functions start here
###########################################
sub PathMaker 
 {
  my $pth = (-e $_[0]) ? $_[0] : $_[1];
  if($pth ne '')
  {
    eval ("use lib \'$pth\';"); return($pth);
  }
 }
###########################################
# On start up makes some profit things :-)
###########################################
sub StartUpInit
{
 my $cnf = PathMaker('./conf/','../conf/');
 require $cnf.'config.pl';
 my $add = PathMaker('./modules/additionals','./additionals');
 $webtools::loaded_functions = 0;
 eval "require '$library_path"."utl.pl'";
 if($@) {DieAlert('Error: Can`t open library utl!');}
 eval "require '$library_path"."cookie.pl'";
 if($@) {DieAlert('Error: Can`t open library cookie!');}
 ###################################################################
 require $driver_path.'sess_flat.pl';
 require $driver_path.'userdefined.pl';
 #####################################################################
 #  ###   ###     ###   ####   #####  #   #  #####  ####             #
 #  #  #  #  #    #  #  #   #    #    #   #  #      #   #            #
 #  #  #  ####    #  #  ####     #    #   #  #####  ####             #
 #  #  #  #  #    #  #  #  #     #     # #   #      #  #             #
 #  ###   ###     ###   #  ##  #####    #    #####  #  ##            #
 #####################################################################
 if($db_support eq 'db_mysql') { require $driver_path.'db_mysql.pl'; $webtools::loaded_functions = $webtools::loaded_functions | 1;}
 if($db_support eq 'db_access') { require $driver_path.'db_access.pl'; $webtools::loaded_functions = $webtools::loaded_functions | 2;}
 if($db_support eq 'db_flat') { require $driver_path.'db_flat.pl'; $webtools::loaded_functions = $webtools::loaded_functions | 4;}
 # TODO: more lines and more db engines
}
##########################################
# I may need something to do on exit
##########################################
sub DestroyScript
{
 1;
}
####################################################################
# High level functions...
####################################################################
sub session_start
{
 my ($dbh,$newv) = @_;
 session_clear_expired($dbh); # Clear all expired sessions!
 my $sid = Get_Old_SID($dbh);     # Try to find old session ID!
 if ($newv) {$sid = '';}
 $local_sess_id = $sid;
 my $sid_time;
 if ($sid eq '')              # Old sessions present?
   {
    $new_session_were_started = 1;
    $sid_time = time();       # Get current time (in ticks)
    $sid_time -= 286520439;   # Try to hide what we doing :-)
    $sid_time = convert_ses_time($sid_time,9);
    rand_srand();             # Reset random generator
    $sid = $sid_time.r_str($charset,$rand_sid_length);  # Create SID string!
    $local_sess_id = $sid;
    if (!insert_sessions_row ($dbh)) { return (0); }
   }
 else
   {   
     $new_session_were_started = 0;
     if(open_session_file($dbh))
       {
        $reg_buffer = load_session_data($dbh);
        if($reg_buffer eq undef) {$reg_buffer = '';}
        save_session_data($reg_buffer,$dbh);            # Here is a place where we automaticly transffer reged data!
        close_session_file($dbh);
       }
     else { return (0); }
     load_registred_vars($reg_buffer);
   }  
 $session_started = 1;  
 return($sid);          # Return new(old) SID!
}
sub session_register
{
  my ($buffer,$dbh) = @_;
  if (!$session_started)
     {
      if(!session_start($dbh))
        {
         return(0);
        }
     }
  if(open_session_file($dbh))
    {
      my $r = save_session_data($buffer,$dbh);
      close_session_file($dbh);
      if(!$r){ return(0); }
    }
  else { return(0); }
  return(1);
}
sub session_destroy
{
  my ($dbh) = @_;
  if($sess_cpg eq 'cookie') # If we using cookies...
   {
    delete_cookie($l_sid);   # That send empty cookie to broser...and browser delete it!
   }
  if(open_session_file($dbh))
    {
      $session_started = 0;
      my $rez = delete_sessions_row($dbh);
      $local_sess_id = '';
      return($rez);
    }
  else { $local_sess_id = ''; return(0); }
}
sub session_id
{
  return($local_sess_id);
}
sub session_set_id_name
{
  $l_sid = shift(@_);
}
sub session_ip_restrict
{
  my ($rmd) = shift(@_);
  if($sess_force_flat eq 'off') ###DB###
  {
  if($rmd or ($rmd =~ m/^on$/i)) { $ip_restrict_mode = 'on'; }
  else { $ip_restrict_mode = 'off'; }
  }
  else
  {
   ###FLAT###
   $ip_restrict_mode = 'off';
  }
}
sub set_script_timeout
{
  $cgi_script_timeout = shift(@_);
  SetCGIScript_Timeout();
}	
sub session_id_name
{
  return($l_sid);
}
sub new_session
{
 return($new_session_were_started);
}
sub session_id_adder   # Add SID ident to all links and forms in source!
{
 my ($source) = @_;
 my $sid = $local_sess_id;
 my $src = href_sid_adder($source,$sid);
 return(action_sid_adder($src,$sid));
}
sub attach_var 
  {
    my ($name,$value) = @_;
    $attached_vars{$name} = $value;
    return (1);
  }
sub disattach_var 
  {
    my ($name) = @_;

    if ( exists $attached_vars{$name} )
      {
      	delete $attached_vars{$name};
      }
     if ($sess_cpg eq 'cookie')
       {
       	if ( exists $sess_cookies{$name} ) { delete_cookie($name); }
       }
    return (1); 	
  }

sub session_expiration
{
  return($sesstimead);
}
sub session_cookie_path
{
  return($cookie_path_cgi);
}

sub register_var
{
  my ($type,$name,@val) = @_;
  my $sp;
  my $reg_buffer = '';
  if ($type eq 'scalar')
    {
     $sp = $uni_sep.'<scalar>:'.$name.':';
     ($val) = @val;
     $reg_buffer = $sp.encode_separator($val,$uni_sep,$uni_gr_sep,$uni_esc);
    }
  if ($type eq 'array')
    {
     $sp = $uni_sep.'<array>:'.$name.':';
     $reg_buffer = $sp;
     my $size = $#val+1;
     $reg_buffer .= "$size".":";
     foreach $scl (@val)
        { 
         $reg_buffer .= $uni_sep."<scalar_a>:".encode_separator($scl,$uni_sep,$uni_gr_sep,$uni_esc);
        }
    }
  if ($type eq 'hash')
    {
     my $h = $val[0];
     my %val = ();
     my $res = ref($h);
     if ($res eq 'HASH'){%val = %$h; @val = %val;}
     else { %val = @val;}
     $sp = $uni_sep.'<hash>:'.$name.':';
     $reg_buffer = $sp;
     my $size = int((scalar @val) / 2);
     $reg_buffer .= "$size".":";
     my $key;
     foreach $key (keys %val)
       { 
        $reg_buffer .= $uni_sep."<scalar_h>:".encode_separator($key,$uni_sep,$uni_gr_sep,$uni_esc).":".encode_separator($val{$key},$uni_sep,$uni_gr_sep,$uni_esc);
       }
    }    	
  return($reg_buffer);
}
sub unregister_var
{
 my ($name,$buffer) = @_;
 
 my $sp = $uni_sep_t;
 if($buffer =~ s/$sp\<scalar\>\:$name\:(.*?)$sp/$uni_sep/s)
   {
     return($buffer);    
   }
 elsif($buffer =~ s/$sp\<scalar\>\:$name\:(.*)//s)
       {
         return($buffer);
       }
 $sp = $uni_sep_t.'(<array>:|<hash>:)'.$name.':';
 my $ps = $uni_sep_t.'<scalar>:';
 my $ps1 = $uni_sep.'<scalar>:';
 my $pa = $uni_sep_t.'<array>:';
 my $pa1 = $uni_sep.'<array>:';
 my $ph = $uni_sep_t.'<hash>:';
 my $ph1 = $uni_sep.'<hash>:';
 if(!($buffer =~ s/$sp(\d{1,})\:(.*?)$ps/$ps1/s))
   {
    if(!($buffer =~ s/$sp(\d{1,})\:(.*?)$pa/$pa1/s))
      {
      	if(!($buffer =~ s/$sp(\d{1,})\:(.*?)$ph/$ph1/s))
          {
           $buffer =~ s/$sp(\d{1,})\:(.*)//s;
          }
      }
   }
 return($buffer);  
}
sub update_var  # Set new value for (not)exists variable (rigistrated)!
{
 my ($type,$name,$buffer,@val) = @_;
 $buffer = unregister_var($name,$buffer);
 $buffer .= register_var($type,$name,@val);
 return($buffer);
}
sub exists_var  # Check wether given var exists!
{
 my ($type,$name,$buffer) = @_;
 if($buffer =~ m/$uni_sep_t\<$type\>\:$name\:/s) {return (1);}
 return(0);
}
sub read_scalar   # Read one scalar from DB (registrated only)
{
  my ($name) = @_;
  return ($SESREG{$name});
}
sub read_array   # Read one array from DB (registrated only)
{
  my ($name) = @_;
  my  $ptr = $SESREG{$name};
  my  @a = @$ptr;
  return(@a);
}
sub read_hash   # Read one hash from DB (registrated only)
{
  my ($name) = @_;
  my  $ptr = $SESREG{$name};
  my  @h = @$ptr;
  return(@h);
}
sub read_form   # Read one scalar from form (browser)
{
  my ($name) = @_;
  if($parsedform) { return ($formdatah{$name}); }
}
sub read_form_array  # Read one scalar from form (browser) but via normal array.
{
  my ($numb) = @_;
  my $kv = $formdataa[$numb];
  my $null = "\0";
  my $kv = m/^(.*?)$null(.*)$/s;
  my @res = ($1,$2);
  return ($res);
}
sub read_var  # Read one scalar from broser (via cookie or just via link/form... - no matter :-)))
{
 my ($name) = @_;
 my $pg = $formdatah{$name};
 my $c = $sess_cookies{$name};
 if(!(exists($formdatah{$name}))) { $pg = '';}
 if(!(exists($sess_cookies{$name}))) {$c = '';}
 my $r;
 if($sess_cpg eq 'cookie')
   {
     $r = $pg;
     if ($c ne '') { return($c); }
     return($r);
   }
  else
   {
     $r = $c;
     if ($pg ne '') { return($pg); }
     return($r);
   }
}


sub encode_separator
  {
    my ($str, $escape, $row_sep, $col_sep) = @_;

    my $esc_hex = uc($escape.join('',unpack("Hh", $escape x 2)));
    my $row_hex = uc($escape.join('',unpack("Hh",$row_sep x 2)));
    my $col_hex = uc($escape.join('',unpack("Hh",$col_sep x 2)));
    
    $escape = quotemeta($escape);
    $row_sep = quotemeta($row_sep);
    $col_sep = quotemeta($col_sep);
    
    $str =~ s/$escape/$esc_hex/gsi;
    $str =~ s/$row_sep/$row_hex/gsi;  
    $str =~ s/$col_sep/$col_hex/gsi;
    return($str);
  }

sub decode_separator
  {
    my ($enstr, $escape, $row_sep, $col_sep) = @_;

    my $esc_hex = uc($escape.join('',unpack("Hh", $escape x 2)));
    my $row_hex = uc($escape.join('',unpack("Hh",$row_sep x 2)));
    my $col_hex = uc($escape.join('',unpack("Hh",$col_sep x 2)));
    
    $enstr =~ s/$esc_hex/$escape/gsi;
    $enstr =~ s/$row_hex/$row_sep/gsi;  
    $enstr =~ s/$col_hex/$col_sep/gsi;
    return($enstr);
  }


sub LoadCfgFile
 {
  my ($a) = @_;
 ################################################################
 # Loading values from 'config.pl'
 ################################################################ 
   require 'config.pl';
   $Mysql::QUIET = $mysqlbequiet;
}  

sub set_printing_mode
{
 my ($flag) = shift(@_);
 my $old = $stdouthandle::var_printing_mode;
 if ($flag eq 'buffered')
   {
    $stdouthandle::var_printing_mode = 'buffered';
   }
 else {
 	if($old eq 'buffered')
 	 {
 	  flush_print();
 	 }
 	$stdouthandle::var_printing_mode = '';
       }
 return($old);
}

sub flush_print     # Flush all data (header and body), coz they are never had been printed!
{
 my ($clear) = @_;
if($clear == 1) { $sess_header_flushed = 1; return;}
 my $oldslcthnd = select(STDOUT);           # Select real output handler
 $i = 0;
 if ($flag_onFlush_Event == 0)
 {
  $flag_onFlush_Event = 1;
  if(exists($webtools::SIGNALS{'OnFlush'}))
     {
       eval {
      	     my $OnEvent_code = $webtools::SIGNALS{'OnFlush'};
      	     &$OnEvent_code;
       	    };
       $flag_onFlush_Event = 0;
      }
 }
 if(!$sess_header_flushed)                  # If Header was not flushed...
 {
  $| = 1;
  $print_header_buffer = "X-Powered-By: WebTools/1.11\n".$print_header_buffer; # Print version of this tool.
  if(($sess_cpg eq 'cookie') and ($local_sess_id ne ''))
    {
     if($sess_cookie ne 'sesstime')
      {
       if(new_session()){
         write_cookie($l_sid,$local_sess_id,'',$cookie_path_cgi);
        }
      }
     else
      {
       if(new_session()){
        write_cookie($l_sid,$local_sess_id,$sesstimead,$cookie_path_cgi);
       }
      }
    }
  if((!($print_header_buffer =~ m/Content\-type\:(.+)/is)) and (!($print_header_buffer =~ m/Status:( *?)204/is)))
    {
        Header(type=>'content');  # Well we forgot to send content-type
    }
  if ($sess_cpg ne 'cookie')
   {
     
     if (scalar(%attached_vars)) # Add attached variables to get/post/cookie
       { 
         while ( my ($name,$value) = each( %attached_vars) )
           {           	
             $print_flush_buffer = href_adder($print_flush_buffer,$name,$value);
             $print_flush_buffer = action_adder($print_flush_buffer,$name,$value);
           }
       }  
   }    
 else
   {
     while ( my ($name,$value) = each( %attached_vars) )
       {           	
         write_cookie($name,$value);
       }
   }  
  print "$print_header_buffer\n";
  $print_header_buffer = '';
  $sess_header_flushed = 1;
 }
 if($local_sess_id ne '')
  {
   if ($sess_cpg ne 'cookie')
     {                        # Well we use not cookies..so we need to add to links and forms SID!
      $print_flush_buffer = session_id_adder($print_flush_buffer);      
     }
  }        
 print $print_flush_buffer;  # Just Print It!
 $print_flush_buffer = '';
 select($oldslcthnd);
}
sub ClearBuffer
{
 $print_flush_buffer = '';
}
sub ClearHeader
{
 $print_header_buffer = '';
 $sess_header_flushed = 0;
 $sentcontent = 0;
}
sub GetCurrentSID
{
 return(Get_Old_SID(shift(@_)));
}
########################################################################
# Low level function...
########################################################################
sub Get_Old_SID
{
 my ($dbh) = @_;
 my $sid;
 my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
 if (!$parsedform)
   {
     Parse_Form();
   }
 if (read_var($l_sid) ne undef)
   {
    $sid = read_var($l_sid);
    if (!check_sid($sid))
      {
        $sid = '';
      }
    else
     {
      if($sess_force_flat eq 'off') ###DB###
      {
       my $r_q = '';
       if($ip_restrict_mode =~ m/^on$/i)
        {
         $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
        }
       my $q = "select S_ID from $sql_sessions_table where S_ID = \'$sid\'".$r_q;
       my $res = sql_query($q,$dbh);
       if ($res ne undef)
        {
         ($my_sid) = sql_fetchrow($res);
         if($my_sid eq $sid) { return($sid); }
         return('');
        }
       else { delete_cookie($sid); return(''); }
      }
      else
      {
       ###FLAT###
       my $res = find_SF_File($tmp.'/',$sid);
       if ($res ne '')
        {
         return($sid);
        }
       else { delete_cookie($sid); return(''); }
      }
     }  
   }
 else { $sid = ''; }
 return($sid);
}
sub r_char
{
 my ($s) = @_;
 $l = length($s);
 $p = rand($l-1);
 return(substr($s,$p,1));
}
sub r_str
{
 my ($cs,$l) = @_;
 my $rs = "";
 for($i=0;$i<$l;$i++)
  {
   $rs .= r_char($cs);
  }
 return($rs);  
}
sub rand_srand()
{
 srand();
}
sub check_sid
{
 my ($sid) = @_;
 if($sid =~ m/^[0-9A-Za-z]*$/i)
  {
   return(1);
  }
 else { return(0);}
}
sub Header
{
  my %arg = @_;
  my $type = $arg{'type'};
  my $val = $arg{'val'};
  
  my $is = $stdouthandle::var_printing_mode eq 'buffered' ? 1 : 0;
  
  if (exists($arg{'type'}))
    {
      if ($type =~ m/content/is)
        {
         if(!$sentcontent)
          {
           $sentcontent = 1;
           if($is) {$print_header_buffer .= "Content-type: ";}
           else { print "Content-type: ";}
           if (exists($arg{'val'}))
             {
             if($is) {$print_header_buffer .= $val."\n";}
             else { print $val."\n";}
             }
           else
             {
              if($is) {$print_header_buffer .= "text/html\n";}
              else { print "text/html\n";}
             }
          }
        }
      if ($type =~ m/cookie/is)
        {
         $print_header_buffer .= "Set-Cookie: ";
         if (exists($arg{'val'}))
           {
             if($val =~ m/^ccn=/si)
               {
                $val =~ s/\ path=.*(;|\b)(.*)/ path=\/$1$2/gsi;
               }
	     if (!($val =~ m/(;| )path ?=.*$/is))
              {
              	if($is) {$print_header_buffer .= $val."; path=$cookie_path_cgi\n";}
                else { print $val."; path=$cookie_path_cgi\n";}
              }
             else
              {
               if($is) {$print_header_buffer .= $val."\n"; }
               else { print $val."\n"; }
              }
           }
         else 
           {
            if($is) {$print_header_buffer .= "\n";}
            else { print "\n"; }
           }
         return;
        }
      if ($type =~ m/raw/is)
        {
         if (exists($arg{'val'}))
           {
            if($is) {$print_header_buffer .= $val;}
            else { print $val; }
           }
         return;
        }
      if ($type =~ m/modified/is)
        {
         $print_header_buffer .= "Last-modified: ";
         if (exists($arg{'val'}))
           {
             my $expi = expires($val);
             if($is) {$print_header_buffer .= $expi."\n";}
             else { print $expi."\n";}
           }
         else {
               my $expi = expires('-1m');
               if($is) {$print_header_buffer .= $expi."\n";}
               else { print $expi."\n";}
              }
         return;
        }
      if ($type =~ m/MIME/is)
        {
         if($is) {$print_header_buffer .= "MIME-version: ";}
         else { print "MIME-version: ";}
         if (exists($arg{'val'}))
           {
             if($is) {$print_header_buffer .= $val."\n";}
             else { print $val."\n";}
           }
         else 
           {
            if($is) {$print_header_buffer .= "1.0\n";}
            else { print "1.0\n";}
           }
         return;
        }
      if ($type =~ m/window/is)
        {
         if($is) {$print_header_buffer .= "Window-target: ";}
         else { print "Window-target: ";}
         if (exists($arg{'val'}))
           {
             if($is) {$print_header_buffer .= $val."\n";}
             else { print $val."\n";}
           }
         else {
                if($is) {$print_header_buffer .= "\n";}
                else { print "\n";}
              }
         return;
        }
      if ($type =~ m/Pragma/is)
        {
         if($is) {$print_header_buffer .= "Pragma: ";}
         else { print "Pragma: ";}
         if (exists($arg{'val'}))
           {
             if($is) {$print_header_buffer .= $val."\n";}
             else { print $val."\n";}
           }
         else { 
         	if($is) {$print_header_buffer .= "no-cache\n";}
         	else { print "no-cache\n";}
              }
         return;
        }
      if ($type =~ m/Expires/is)
        {
         if($is) {$print_header_buffer .= "Expires: ";}
         else { print "Expires: ";}
         if (exists($arg{'val'}))
           {
             my $expi = expires($val);
             if($is) {$print_header_buffer .= $expi."\n";}
             else { print $expi."\n";}
           }
         else {
         	my $expi = expires('-1m');
                if($is) {$print_header_buffer .= $expi."\n";}
                else { print $expi."\n";}
              }
         return;
        }
      if ($type =~ m/Referrer/is)
        {
         if($is) {$print_header_buffer .= "Referrer: ";}
         else { print "Referrer: ";}
         if (exists($arg{'val'}))
           {
             if($is) {$print_header_buffer .= $val."\n";}
             else { print $val."\n";}
           }
         else {
         	if($is) {$print_header_buffer .= "\n";}
         	else { print "\n";}
               }
         return;
        }
    }
}
sub href_sid_adder
{
 my ($source,$sid) = @_;
 my ($name,$value) = ($l_sid,$sid);
 my $url;
 my $src = $source;
 my $match = $source;
    $source = '';
 my $after,$before,this;
 if($session_started)
 {
  if(!($src =~ s! *href *?= *?(\'|\")?(.*?)(\'|\"|\>\ )?!do{
    $match =~ m/( *href *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/is;
    $url = $3;   #Matched string
    $before = $`;
    $after = $';
    $this = $&;
    if($url =~ m/.*?\.(cgi|pl).*/is)
     {
      if ($url =~ s/(.*?\?.*)/$1\&$name\=$value/is)
        {
        }
      else
        {
         $url =~ s/(.*)/$1\?$name\=$value/is;
        }
     }
      $this =~ s/( *?href *?= *?)(\'|\"|)(.*?)(\'|\"| |>)/$1$2$url$4/is;
    
      $source .= $before.$this;
      $match = $after;
   };!isge)) { return($src); } 
   $source .= $after;
 }
 else { return($src); } 
   return($source); 
} 
sub href_adder
{
 my ($source,$name,$value) = @_;
 my $url;
 my $src = $source;
 my $match = $source;
    $source = '';
 my $after,$before,this;
 
  if(!($src =~ s! *href *?= *?(\'|\")?(.*?)(\'|\"|\>\ )?!do{
    $match =~ m/( *href *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/is;
    $url = $3;   #Matched string
    $before = $`;
    $after = $';
    $this = $&;
    if($url =~ m/.*?\.(cgi|pl).*/is)
     {
      if ($url =~ s/(.*?\?.*)/$1\&$name\=$value/is){}
      else
        {
         $url =~ s/(.*)/$1\?$name\=$value/is;
        }
     }
      $this =~ s/( *?href *?= *?)(\'|\"|)(.*?)(\'|\"| |>)/$1$2$url$4/is;
    
      $source .= $before.$this;
      $match = $after;
   };!isge)) { return($src); } 
   $source .= $after;
 
 
   return($source); 
}
sub action_sid_adder
{
 my ($source,$sid) = @_;
 my ($name,$value) = ($l_sid,$sid);
 my $url;
 my $src = $source;
 my $match = $source;
    $source = '';
 my $after,$before,this;
 if($session_started)
 {
  if($src =~ m/\ +(action *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/is)
   {
    $src =~ s!\ +action *?= *?(\'|\")?(.*?)(\'|\")?!do{
    $match =~ m/\ +(action *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/is;
    $url = $3;   #Matched string
    $before = $`;
    $after = $';
    $this = $&;
    
    if ($url =~ s/(.*?\?.*)/$1\&$name\=$value/is){}
    else
      {
       $url =~ s/(.*)/$1\?$name\=$value/is;
      }
    
    $this =~ s/(\ +action *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/$1$2$url$4/is;
    
    $source .= $before.$this;
    $match = $after;
   };!isge;
   $source .= $after;
  } else { return ($src); }
 }
 else { return($src); }   
   return($source);
}
sub action_adder
{
 my ($source,$name,$value) = @_;
 my $url;
 my $src = $source;
 my $match = $source;
    $source = '';
 my $after,$before,this;
 
 if($src =~ m/\ +(action *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/is)
   {
    $src =~ s!\ +action *?= *?(\'|\")?(.*?)(\'|\")?!do{
    $match =~ m/\ +(action *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/is;
    $url = $3;   #Matched string
    $before = $`;
    $after = $';
    $this = $&;
    
    if ($url =~ s/(.*?\?.*)/$1\&$name\=$value/is)
      {
      }
    else
      {
       $url =~ s/(.*)/$1\?$name\=$value/is;
      }
    
    $this =~ s/(\ +action *?= *?)(\'|\"|)(.*?)(\'|\"|\ |\>)/$1$2$url$4/is;
    
    $source .= $before.$this;
    $match = $after;
   };!isge;
   $source .= $after;
  } else { return ($src); }
 
    
   return($source);
}
sub delete_sessions_row
{
  my ($dbh) = @_;
  my $sid = $local_sess_id;
  my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
  my $r_q = '';
  if($sess_force_flat eq 'off') ###DB###
  {
   if($ip_restrict_mode =~ m/^on$/i)
    {
     $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
    }
   my $res = sql_query("delete from $sql_sessions_table where S_ID = \'$sid\'".$r_q,$dbh);
   if ($res ne undef)
     {
      return(1);
     }
  }
 else
  {
   ###FLAT###
   return(destroy_SF_File($tmp.'/',$sid));
  }
 return(0);
}
sub open_session_file
{
  my ($dbh) = @_;
  my $sid = $local_sess_id;
  my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
  my $r_q = '';
  if($ip_restrict_mode =~ m/^on$/i)
   {
    $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
   }
  my $q = "update $sql_sessions_table set FLAG = \'1\' where S_ID = \'$sid\' and FLAG = \'0\'".$r_q;
  my $c = $wait_for_open / $wait_attempt; 
  my $i;
  for ($i=0;$i<$wait_attempt;$i++)
    {
     my $re;
     if($sess_force_flat eq 'off') ###DB###
      {
       $re = sql_query($q,$dbh);
       if($re ne undef) {return(1);}
      }
     else
      {
       ###FLAT###
       $re = osetflag_SF_File($tmp.'/',$sid);
       if($re == -1) {$re = undef;}
       else {return(1);} # File can be opened!
      }
     select(undef,undef,undef,$c);
    }
  onLockedFileErrorEvent();
  return(0);   # Sorry, at this moment file can`t be opened!
}
sub close_session_file 
{
  my ($dbh) = @_;
  my $sid = $local_sess_id;
  my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
  my $r_q = '';
  if($ip_restrict_mode =~ m/^on$/i)
   {
    $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
   }
  my $q = "update $sql_sessions_table set FLAG = \'0\' where S_ID = \'$sid\'".$r_q;

  if($sess_force_flat eq 'off') ###DBD###
   {
    if (sql_query($q,$dbh) ne undef) { return(1); }
    return(0);
   }
  else
  {
   ###FLAT###
   $sess_force_flat = 'off';
   $re = csetflag_SF_File($tmp.'/',$sid);
   return(1);
  }
}

sub load_registred_vars
{
  my ($buffer) = @_;
  my $c = 0,$i = 0;
  my $a_name,$s_name,$h_name,$val;
  my @a_data = ();
  my @h_data = ();
  my @pars = split(/$uni_sep_t/s,$buffer);
  foreach $line (@pars)
   { 
    if ($c == 0)
     {
      if ($line =~ m/\<array\>\:(.*?)\:(\d{1,})\:(.*)/s)
        {
         $c = $2;
         $a_name = $1;
         $val = '';
         @a_data = ();
        }
      if ($line =~ m/\<hash\>\:(.*?)\:(\d{1,})\:(.*)/s)
        {
         $c = $2;
         $h_name = $1;
         $val = '';
         @h_data = ();
        }
      if ($line =~ m/\<scalar\>\:(.*?)\:(.*)/s)
        {
         $s_name = $1;
         $val = $2;
         make_scalar_from($s_name,decode_separator($val,$uni_sep,$uni_gr_sep,$uni_esc));
        }
     }
    else
     {
       if ($line =~ m/\<scalar_a\>\:(.*)/s)
         {
          my $scl = decode_separator($1,$uni_sep,$uni_gr_sep,$uni_esc);
          push (@a_data,$scl);
          $c --;
          if (!$c) { make_array_from($a_name,@a_data); }
         }
       if ($line =~ m/\<scalar_h\>\:(.*?)\:(.*)/s)
         {
          my $n = $1;
          my $v = $2;
          my $n = decode_separator($n,$uni_sep,$uni_gr_sep,$uni_esc);
          my $v = decode_separator($v,$uni_sep,$uni_gr_sep,$uni_esc);
          push (@h_data,$n);push (@h_data,$v);
          $c --;
          if (!$c) { make_hash_from($h_name,@h_data); }
         }
     } 
   }
}
sub make_scalar_from
{
 my ($s_name,$val) = @_;
 $SESREG{$s_name} = $val;
}
sub make_array_from
{
 my ($a_name,@a_data) = @_;
 $SESREG{$a_name} = \@a_data;
}
sub make_hash_from
{
 my ($h_name,@h_data) = @_;
 $SESREG{$h_name} = \@h_data;
}
sub save_session_data   # ($session_ID,$buffer,$database_handler) // Save into DB DATA field
{
 my ($buffer,$dbh) = @_;
 my $sid = $local_sess_id;
 my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
 my $r_q = '';
 if($sess_force_flat eq 'off') ###DB###
 {
  if($ip_restrict_mode =~ m/^on$/i)
    {
     $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
    }
  my $buf = sql_quote($buffer,$dbh);
  my $q = "update $sql_sessions_table set DATA = $buf where S_ID = \'$sid\'".$r_q;
  if (sql_query($q,$dbh) ne undef) { return(1); }
 }
 else
 {
  ###FLAT###
  write_SF_File($tmp.'/',$sid,$buffer);
  return(1);
 }
 return(0);
}
sub load_session_data   # ($session_ID,$database_handler) // Load DATA from table
{
 my ($dbh) = @_;
 my $sid = $local_sess_id;
 my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
 my $r_q = '';
 my @arr = ();
 if($sess_force_flat eq 'off') ###DB###
 {
  if($ip_restrict_mode =~ m/^on$/i)
    {
     $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
    }
  my $q = "select DATA from $sql_sessions_table where S_ID = \'$sid\'".$r_q;
  my $res = sql_query($q,$dbh);
  if ($res eq undef) { return(undef); }
  @arr = sql_fetchrow($res);
 }
 else
 {
  ###FLAT###
  return(read_SF_File($tmp.'/',$sid));
 }
 return($arr[0]);     # Return DATA field
}
sub RunScript
{
 Parse_Form();
 if(($perl_html_dir eq '') or ($perl_html_dir =~ m/^(\\|\/)$/si))
   {
    print "<BR><h3><B><font color='red'>Security hole!!!</font> Your default script direcotry (htmls) is leaved empty or<BR>";
    print " it is pointed to your ROOT directory! <BR>";
    print "Script abort immediately!</h3></B>";
    die ':QUIT:';
   }
 $p_file_name_N001 = read_form('file');
 $p_file_checked_done_N001 = 0;
 if ($p_file_name_N001 =~ m/^[A-Za-z0-9-_.\/]*$/is)
   {
    if (!($p_file_name_N001 =~ m/\.\./i) and (!($p_file_name_N001 =~ m/\.\//i))) {
       if (($p_file_name_N001 =~ m/\.html$/i) or ($p_file_name_N001 =~ m/\.htm$/i) or ($p_file_name_N001 =~ m/\.cgi$/i) or
           ($p_file_name_N001 =~ m/\.whtml$/i) or ($p_file_name_N001 =~ m/\.cgihtml$/i))
         {
          $p_file_name_N001 =~ m/^(.*)\.(.*)$/i;
          my $body = $1;
          my $ext = $2;
          my $exname;
          if($treat_htmls_ext[0] ne '')
           {
            foreach $exname (@treat_htmls_ext)
             {
              if(-e $perl_html_dir.$body.'.'.$exname)
               {
                $p_file_name_N001 = $body.'.'.$exname;
               }
              else
               {
               	if($exname =~ m/^$ext$/i) {last;}
               }
             }
           }
          $p_file_checked_done_N001 = 1;
         }      
       }
   }
 if ($p_file_checked_done_N001)   
  {
   if(!open(FILE_H_OPEN_N001,$perl_html_dir.$p_file_name_N001))
     {
      Header(type => 'content');
      $print_flush_buffer = '';
      flush_print();
      print "<br><font color='red'><h2>Error: Incorrect request($perl_html_dir$p_file_name_N001)!</h2></font>";
      onExit();
      exit;
     }
   local $/;
   undef $/;
   binmode(FILE_H_OPEN_N001);
   $p_file_buf_N001 = <FILE_H_OPEN_N001>;
   close (FILE_H_OPEN_N001);
   $/ = "\n";
   $p_file_buf_N001 =~ s/\r\n/\n/gs;
   $p_file_buf_N001 =~ s/\<\!\-\- PERL:(.*?)(\<\?perl.*?\?\>.*?)\/\/\-\-\>\n?/$2/gsi;
   $p_file_buf_N001 =~ s/\<\!\-\- PERL:(.*?)\/\/\-\-\>\n?//gsi;
   $p_file_buf_N001 = pre_process_templates($p_file_buf_N001);  # Process all build-in templates
   
   # Remove all the COMMENTS!!! That will reduce perl computing and printing!                
   ExecuteHTMLfile($p_file_name_N001,$p_file_buf_N001);  
   onExit();
   if(exists($webtools::SIGNALS{'OnExit'}))
     {
      eval {
      	    my $OnExit_code = $webtools::SIGNALS{'OnExit'};
      	    &$OnExit_code;
      	   };
     }
  }
 else
  {
   Header(type => 'content');
   $print_flush_buffer = '';
   flush_print();
   print "<br><font color='red'><h2>Error: Invalid file request!</h2></font>";
   onExit();
   exit;
  }
}
sub ExecuteHTMLfile
{
 my ($f_name,$p_buf_N001) = @_;
 my @html_N001 = split(/\n?\<\?perl/is,$p_buf_N001);
 my $a_N001;
 my $error_locator_N001 = 1;
 my $all_code_in_one = "\n"; #"$globvars"."\n";
 foreach $l_N001 (@html_N001)
  {
   $l_N001 =~ s/(.*)\?\>\n?//is;
   push(@h_N001,$l_N001);
  }
 my @code_N001 = ();
 $p_buf_N001 =~ s/\<\?perl *(.*?)\?\>/do{
  $a_N001 = $1;
  if ($a_N001 ne '') { push(@code_N001,$a_N001); }
 };/isge;
 my $i_N001 = 0;
 foreach $l_N001 (@h_N001)
  {
    chomp($l_N001);
    if($l_N001 ne '')
      {
       $all_code_in_one .= '$print_flush_buffer_n = << \'ALL_HTML_CODE_N001\';'."\n$l_N001\nALL_HTML_CODE_N001\n".'$print_flush_buffer_n =~ s/\n$//gs;'."\n".'$print_flush_buffer .= $print_flush_buffer_n;'."\n";
      }
    my $cd_N001 = $code_N001[$i_N001]; $i_N001++;
    $all_code_in_one .= $cd_N001;
  }
 $all_code_in_one .= "\n".'$error_locator_N001 = 0;';
 SetCGIScript_Timeout();
 eval $all_code_in_one;
 my $cd = $@;
 my $codeerr = $cd;
 if($error_locator_N001)
   {
    onExit();
    if($cd =~ m/\:QUIT\:(.*)/i) 
      {
       if(exists($webtools::SIGNALS{'OnError'}))
         {
          eval {
      	        my $OnEvent_code = $webtools::SIGNALS{'OnError'};
      	        &$OnEvent_code($1);
      	       };
         }
       return;
      }
    if($cd =~ m/\:EXIT\:(.*)/i) 
      {
       return;
      }
    Header(type => 'content');
    $print_flush_buffer = '';
    flush_print();
    print "<br><font color='red'><h3>Perl Subsystem: Syntax error in code(<font color='blue'>$f_name</font>)!</h3>";
    $codeerr =~ s/\r\n/\n/sg;
    $codeerr =~ s/\n/<BR>/sgi;
    my $res = $debugging eq 'on' ? "<br>$codeerr</font>" : "";
    print $res;
    exit;
   }
}
sub b_print # Only for backware compatibility!
{
  my ($p) = @_;
  $print_flush_buffer .= $p;
}
###########################################
# Cookies
###########################################
sub read_cookie   # Read one scalar from cookie
{
 my ($name) = @_;
 return($sess_cookies{$name});
}
sub write_cookie
{
 my ($name,$value,$expires,$path,$domain) = @_;
 SetCookieExpDate($expires) if($expires ne '');
 SetCookiePath($path) if($path ne '');
 SetCookieDomain($domain) if($domain ne '');
 my $cuky = SetCookies($name,$value);
 Header(type=>'raw',val=>$cuky);
 return(1);
}
sub delete_cookie
{
 my ($name) = @_;
 my $expires = '-1m';
 SetCookieExpDate($expires);
 my $cuky = SetCookies($name,'');
 Header(type=>'raw',val=>$cuky); # Expires data is -1 minute!
 return(1);
}

########################################################
sub Default_CGI_Script_ALARM_SUB
 {
  if(exists($webtools::SIGNALS{'OnTimeOut'}))
     {
      eval {
      	    my $OnEvent_code = $webtools::SIGNALS{'OnTimeOut'};
      	    &$OnEvent_code;
      	   };
     }
  else
   {
    ClearHeader();
    ClearBuffer(); 
    Header(type=>'content');
    print "<center><B>Error: Script timeouted!</B></center>\n";
   }
  CORE::exit;
 }
sub SetCGIScript_Timeout
{
 if((defined($cgi_script_timeout)) and ($cgi_script_timeout != 0) and ($cgi_script_timeout > 1))
  {
   $SIG{'ALRM'} = \&webtools::Default_CGI_Script_ALARM_SUB;
my $script_time_eval = << "TIME_EVAL_TERMINATOR";
   alarm($cgi_script_timeout);
TIME_EVAL_TERMINATOR
   eval $script_time_eval;
  }
}
##########################################################################
sub base_rand_maker
{
 my ($n) = @_;
 srand($n);
 my $i = rand(12);
 my $load = $l_charset[$i];
 return(substr($load,$n,1))
}
sub convert_ses_time
{
 my ($cs,$l) = @_;
 my $rs = "";
 for($i=0;$i<$l;$i++)
  {
   $n = substr($cs,$i,1);
   $rs .= base_rand_maker($n);
  }
 return($rs);
}
sub DieAlert
 {
  ClearBuffer();
  ClearHeader();
  print '<font color="red"><B><h2>'.shift().'</h2></B></font>';
  fush_print();
  exit;
 }
############################################
# Parse Form
############################################
sub Parse_Form
{
 return (1);
}
#####################################################################
# User Defined Functions
#####################################################################

#####################################################################
sub onExit
{ 
  # now we are going to erase all the files uploaded on the server ...
  my $delete_uploaded_files = << 'EVAL_TERMINATOR';
  while ( my ($file_name,$full_path_to_file) = each( %uploaded_files) )
    {
      if (-e $full_path_to_file)
        {
          unlink ($full_path_to_file); 
        }
    }
 DB_OnDestroy();
EVAL_TERMINATOR
 eval $delete_uploaded_files;
 return(1);
}

sub onLockedFileErrorEvent
{
 Header(type => 'content');
 $print_flush_buffer = '';
 flush_print();
 print "<br><font color='red'><h3>Error: Server is too busy! Please press Ctrl+R after few seconds (20-30)</h3></font>";
 onExit();
 exit;
}

# Follow code process all supported INLINE tags for fast code writings!
sub pre_process_templates ($)
{
 my $sys_temp_buffer = shift(@_);
 my $sys_binlinet = '\<\!\-\-\©INLINE\©\>';   # <!--©INLINE©>
 my $sys_einlinet = '\<\/\©INLINE\©\-\-\>';   # </©INLINE©-->
 my $sys_binlinep = '\<\!\-\-\©INPERL\©\>';   # <!--©INPERL©>
 my $sys_einlinep = '\<\/\©INPERL\©\-\-\>';   # </©INPERL©-->
 my $sys_include_file = '\<\!\-\-\©INCLUDE\©(.*?)\©\-\-\>';   # <!--©INCLUDE©file.ext©-->
 
 my $work_buffer = $sys_temp_buffer;
 
 $sys_temp_buffer =~ s#$sys_include_file#do{
    my $sys_prd_template;
    if(open(SYS_PRE_PROCESS_TEMPLATES_FILE,$1))
     {
      binmode(SYS_PRE_PROCESS_TEMPLATES_FILE);
      local $/ = undef;
      $sys_prd_template = <SYS_PRE_PROCESS_TEMPLATES_FILE>;
      $sys_prd_template =~ s/\r\n/\n/gs;
      $sys_prd_template =~ s/\<\!\-\- PERL:(.*?)(\<\?perl.*?\?\>.*?)\/\/\-\-\>\n?/$2/gsi;
      $sys_prd_template =~ s/\<\!\-\- PERL:(.*?)\/\/\-\-\>\n?//gsi;
      close(SYS_PRE_PROCESS_TEMPLATES_FILE);
     }
    else {$sys_prd_template = '';}
    $work_buffer =~ s/$sys_include_file/$sys_prd_template/si;
   };#sgie;
 
 $sys_temp_buffer = $work_buffer;
 
 $sys_temp_buffer =~ s#$sys_binlinet(.*?)$sys_einlinet#do{
    my $sys_prd_template = sys_make_template_code($1,'h');
    $work_buffer =~ s/$sys_binlinet(.*?)$sys_einlinet/$sys_prd_template/si;
   };#sgie;
 
 $sys_temp_buffer = $work_buffer;
 $sys_temp_buffer =~ s#$sys_binlinep(.*?)$sys_einlinep#do{
    my $sys_prd_template = sys_make_template_code($1,'p');
    $work_buffer =~ s/$sys_binlinep(.*?)$sys_einlinep/$sys_prd_template/si;
   };#sgie;
 
 return($work_buffer);
}

# This sub process all supported form INLINE template formats
sub sys_make_template_code
{
 my $sys_my_pre_process_tempf = shift(@_);
 my $sys_my_pre_process_ph_b = "<?perl \n";
 my $sys_my_pre_process_ph_e = "\n?>";
 my $sys_my_pre_process_print = "print ";
 $syspre_process_counter++;
 
 if($_[0] eq 'p')
   {
    $sys_my_pre_process_ph_b = "\n";
    $sys_my_pre_process_ph_e = "\n";
    $sys_my_pre_process_print = '$_ = ';
   }
 
 # ----- Make code for simple TEMPLATES -----
 # example: <§TEMPLATE:7:$val:§>
 if($sys_my_pre_process_tempf =~ m/\<\§TEMPLATE\:(\d{1,})\:(.*?)\:\§\>/si)
  {
   my $sys_my_pre_process_num = $1;
   my $sys_my_pre_process_val = $2;
   if($sys_my_pre_process_val =~ m/^(\$|\@|\%)/s)
     {
      $sys_my_pre_process_sys_code = $sys_my_pre_process_ph_b.$sys_my_pre_process_print.'('.$sys_my_pre_process_val.');'.$sys_my_pre_process_ph_e;
     }
   else
     {
      $sys_my_pre_process_sys_code = $sys_my_pre_process_ph_b.$sys_my_pre_process_print."('".$sys_my_pre_process_val."');".$sys_my_pre_process_ph_e;
     }
   return($sys_my_pre_process_sys_code);
  }
  
 # ----- Make code for XREADER -----
 if($sys_my_pre_process_tempf =~ m/\<XREADER:\d{1,}\:(.*?)\:(.*?)\>/si)
  {
    my $sys_my_pre_process_sys_code = $sys_my_pre_process_ph_b.q# if($system_database_handle eq undef)
        {
          my $rztl_sconn = sql_connect(); 
          if($rztl_sconn eq undef) { print '?C?'; exit(-1);}
        }
     if(!($webtools::loaded_functions & 8)) {eval "require '$library_path"."xreader.pl'";}
     xreader_dbh($system_database_handle);#;
     
   $sys_my_pre_process_tmp_eval = '$sys_my_pre_process_val_N_'.$syspre_process_counter.' = $sys_my_pre_process_tempf;';
   eval $sys_my_pre_process_tmp_eval;
   
   $sys_my_pre_process_sys_code .= "\n".$sys_my_pre_process_print.'sys_run_time_process_xread('.'$sys_my_pre_process_val_N_'.$syspre_process_counter.');'.$sys_my_pre_process_ph_e;
   return($sys_my_pre_process_sys_code);
  }
  
 # ----- Make code for SQL Templates -----
 if($sys_my_pre_process_tempf =~ m/\<S\©L\:\d{1,}\:(.*?)\:\d{1,}\:\d{1,}\:\d{1,}\:\d{1,}\:S\©L\>/si)
  {
    my $sys_my_pre_process_sys_code = $sys_my_pre_process_ph_b.q# if($system_database_handle eq undef)
        {
          my $rztl_sconn = sql_connect(); 
          if($rztl_sconn eq undef) { print '?C?'; exit(-1);}
        }
     if(!($webtools::loaded_functions & 8)) {eval "require '$library_path"."xreader.pl'";}
     xreader_dbh($system_database_handle);#;

   $sys_my_pre_process_tmp_eval = '$sys_my_pre_process_val_N_'.$syspre_process_counter.' = $sys_my_pre_process_tempf;';
   eval $sys_my_pre_process_tmp_eval;
   
   $sys_my_pre_process_sys_code .= "\n".$sys_my_pre_process_print.'sys_run_time_process_sql('.'$sys_my_pre_process_val_N_'.$syspre_process_counter.');'.$sys_my_pre_process_ph_e;
   return($sys_my_pre_process_sys_code);
  }
  
 # ----- Make code for SQLVAR Templates -----
 if($sys_my_pre_process_tempf =~ m/\<S\©LVAR\:(.+?)\:S\©L\>/si)
  {
    my $sys_my_pre_process_sys_code = $sys_my_pre_process_ph_b.q# if($system_database_handle eq undef)
        {
          my $rztl_sconn = sql_connect(); 
          if($rztl_sconn eq undef) { print '?C?'; exit(-1);}
        }
     if(!($webtools::loaded_functions & 8)) {eval "require '$library_path"."xreader.pl'";}
     xreader_dbh($system_database_handle);#;

   $sys_my_pre_process_tmp_eval = '$sys_my_pre_process_val_N_'.$syspre_process_counter.' = $sys_my_pre_process_tempf;';
   eval $sys_my_pre_process_tmp_eval;
   
   $sys_my_pre_process_sys_code .= "\n".$sys_my_pre_process_print.'sys_run_time_process_sqlvar('.'$sys_my_pre_process_val_N_'.$syspre_process_counter.');'.$sys_my_pre_process_ph_e;
   return($sys_my_pre_process_sys_code);
  }
  
 # ----- Make code for MENUSELECT -----
 if($sys_my_pre_process_tempf =~ m/\<MENUSELECT\:\$(.*?)\:(.*?)\:\$(.*?)\:\$(.*?)\:\$(.*?)\:\$(.*?)\:\>/si)
  {
    my $sys_my_pre_process_sys_code = $sys_my_pre_process_ph_b.q# if($system_database_handle eq undef)
        {
          my $rztl_sconn = sql_connect(); 
          if($rztl_sconn eq undef) { print '?C?'; exit(-1);}
        }
     if(!($webtools::loaded_functions & 8)) {eval "require '$library_path"."xreader.pl'";}
     xreader_dbh($system_database_handle);#;

   $sys_my_pre_process_tmp_eval = '$sys_my_pre_process_val_N_'.$syspre_process_counter.' = $sys_my_pre_process_tempf;';
   eval $sys_my_pre_process_tmp_eval;
   
   $sys_my_pre_process_sys_code .= "\n".$sys_my_pre_process_print.'sys_run_time_process_menuselect('.'$sys_my_pre_process_val_N_'.$syspre_process_counter.');'.$sys_my_pre_process_ph_e;
   return($sys_my_pre_process_sys_code);
  }
  
 return('<?perl print "?Err?"; ?>');
}

# That sub process XREAD template in run-time and it is a part of INLINE feature.
# example: <XREADER:1:bestbuy.jhtml:$first_param,$second_param>
sub sys_run_time_process_xread
{
 my $sys_my_pre_process_tempf = shift(@_);
 if($sys_my_pre_process_tempf =~ m/\<XREADER:(\d{1,})\:(.*?)\:(.*?)\>/si)
  {
   my $sys_my_pre_process_numb = $1;
   my $sys_my_pre_process_file = $2;
   my $sys_my_pre_process_vals = $3;
   my @sys_my_pre_process_aval = split('\,',$sys_my_pre_process_vals);
   my @sys_my_pre_process_all = ();
   foreach $sys_my_pre_process_aself (@sys_my_pre_process_aval)
    {
     if($sys_my_pre_process_aself =~ m/^(\$|\@|\%)/s)
      {
       my $sys_my_pre_process_eval = 'push (@sys_my_pre_process_all,'.$sys_my_pre_process_aself.');';
       eval $sys_my_pre_process_eval;
      }
     else
      {
       my $sys_my_pre_process_eval = 'push (@sys_my_pre_process_all,'."'".$sys_my_pre_process_aself."'".');';
       eval $sys_my_pre_process_eval;
      }
    }
   $sys_my_pre_process_sys_code = xreader($sys_my_pre_process_numb,$sys_my_pre_process_file,@sys_my_pre_process_all);
   return($sys_my_pre_process_sys_code);
  }
}

# That sub process SQL template in run-time and it is a part of INLINE feature.
# example: <S©L:1:"select USER,ID from demo_users where id=1;":1:1:1:1:S©L>
sub sys_run_time_process_sql
{
 my $sys_my_pre_process_tempf = shift(@_);
 if($sys_my_pre_process_tempf =~ m/(\<S\©L\:\d{1,}\:)(.*?)(\:\d{1,}\:\d{1,}\:\d{1,}\:\d{1,}\:S\©L\>)/si)
  {
   my $sys_my_pre_process_beg  = $1;
   my $sys_my_pre_process_data = $2;
   my $sys_my_pre_process_end  = $3;
   my $sys_my_pre_process_tmp  = 0;
   my $sys_pre_process_replce = '';
  
   if($sys_my_pre_process_data =~ m/([\ \']{0,})\$(.*?)([\'\ \;\"])/si)
     {
      my $sys_pre_process_tmp_1 = $1;
      my $sys_pre_process_tmp_2 = $2;
      my $sys_pre_process_tmp_3 = $3;
      my $sys_pre_process_tmp_4 = '$sys_pre_process_replce = $'.$sys_pre_process_tmp_2.';';
      eval $sys_pre_process_tmp_4;
      $sys_pre_process_replce = $sys_pre_process_tmp_1.$sys_pre_process_replce.$sys_pre_process_tmp_3;
      $sys_my_pre_process_data =~ s/([\ \']{0,})\$(.*?)([\'\ \;\"])/$sys_pre_process_replce/si;
     }
   $sys_my_pre_process_tempf = $sys_my_pre_process_beg.$sys_my_pre_process_data.$sys_my_pre_process_end;
   return(_mem_xreader($sys_my_pre_process_tempf));
  }
}

# That sub process SQLVAR template's variables in run-time and it is a part of INLINE feature.
# example: <S©LVAR:1:S©L>
sub sys_run_time_process_sqlvar
{
 my $sys_my_pre_process_tempf = shift(@_);
 if($sys_my_pre_process_tempf =~ m/(\<S\©LVAR)(\:.*?\:)(S\©L\>)/si)
  {
   my $sys_my_pre_process_beg  = $1;
   my $sys_my_pre_process_data = $2;
   my $sys_my_pre_process_end  = $3;
   my $sys_my_pre_process_tmp  = 0;
   my $sys_pre_process_replce = '';
  
   if($sys_my_pre_process_data =~ m/(\:)\$(.*?)(\:)/si)
     {
      my $sys_pre_process_tmp_1 = $1;
      my $sys_pre_process_tmp_2 = $2;
      my $sys_pre_process_tmp_3 = $3;
      my $sys_pre_process_tmp_4 = '$sys_pre_process_replce = $'.$sys_pre_process_tmp_2.';';
      eval $sys_pre_process_tmp_4;
      $sys_pre_process_replce = $sys_pre_process_tmp_1.$sys_pre_process_replce.$sys_pre_process_tmp_3;
      $sys_my_pre_process_data =~ s/(\:)\$(.*?)(\:)/$sys_pre_process_replce/si;
     }
   $sys_my_pre_process_tempf = $sys_my_pre_process_beg.$sys_my_pre_process_data.$sys_my_pre_process_end;
   return(_mem_xreader($sys_my_pre_process_tempf));
  }
}

# That sub process MENUSELECT template in run-time and it is a part of INLINE feature.
# exmp: <MENUSELECT:$SOURCE:"SELECT MenuState FROM MyTable WHERE Condition1 = $C1 AND ...":\@DB_VALUES:\@TEMPLATE_NUMBERS:\@HTML_VALUES:$dbh:>
sub sys_run_time_process_menuselect
{
 my $sys_my_pre_process_tempf = shift(@_);
 if($sys_my_pre_process_tempf =~ m/\<MENUSELECT\:\$(.*?)\:\$(.*?)\:\$(.*?)\:\$(.*?)\:\$(.*?)\:\$(.*?)\:\>/si)
  {
   my $sys_my_pre_process_src  = $1;
   my $sys_my_pre_process_sql  = $2;
   my $sys_my_pre_process_dbv  = $3;
   my $sys_my_pre_process_tem  = $4;
   my $sys_my_pre_process_htm  = $5;
   my $sys_my_pre_process_dbh  = $6;
   my $sys_pre_process_replce = '';

   my $sys_my_pre_process_tmp = '$sys_my_pre_process_src = $'.$sys_my_pre_process_src.';';
   eval $sys_my_pre_process_tmp;
   $sys_my_pre_process_tmp = '$sys_my_pre_process_dbv = $'.$sys_my_pre_process_dbv.';';
   eval $sys_my_pre_process_tmp;
   $sys_my_pre_process_tmp = '$sys_my_pre_process_tem = $'.$sys_my_pre_process_tem.';';
   eval $sys_my_pre_process_tmp;
   $sys_my_pre_process_tmp = '$sys_my_pre_process_htm = $'.$sys_my_pre_process_htm.';';
   eval $sys_my_pre_process_tmp;
   $sys_my_pre_process_tmp = '$sys_my_pre_process_sql = $'.$sys_my_pre_process_sql.';';
   eval $sys_my_pre_process_tmp;
   $sys_my_pre_process_tmp = '$sys_my_pre_process_dbh = $'.$sys_my_pre_process_dbh.';';
   eval $sys_my_pre_process_tmp;

   if(($sys_my_pre_process_dbh eq '') or ($sys_my_pre_process_dbh eq undef))
      {$sys_my_pre_process_dbh = $system_database_handle;}
   
   my @sys_my_pre_process_dbv_a  = @$sys_my_pre_process_dbv;
   my @sys_my_pre_process_tem_a  = @$sys_my_pre_process_tem;
   my @sys_my_pre_process_htm_a  = @$sys_my_pre_process_htm;

   $sys_my_pre_process_src = MenuSelect($sys_my_pre_process_src,$sys_my_pre_process_sql,$sys_my_pre_process_dbv,
                                        $sys_my_pre_process_tem,$sys_my_pre_process_htm,$sys_my_pre_process_dbh);
   return($sys_my_pre_process_src);
  }
}


1;  # Well done...
__END__

=head1 NAME

 webtools.pm - Full featured WEB Development Tools (compare with Php language) in Perl syntax

=head1 DESCRIPTION

=over 4

This package is written in pure Perl and its main purpose is: to help all Web developers. 
It brings in self many features of modern Web developing:

  -  Grabs best of Php but in Perl syntax.
  -  Embedded Perl into HTML files.
  -  Buffered output.
  -  Easy reading input forms and cookies using global variables.
  -  Flat files database support.
  -  MySQL/MS Access support.
  -  Full Sessions support (via flat files or via DB)
  -  Easy User support (SignIn / SignUp)
  -  Cookies support.
  -  Attached variables.
  -  Html/SQL templates and variables.
  -  Mail functions (plain/html mails/uploads)
  -  Upload/download functions via Perl scripts.
  -  DES III encription/decription in MIME style
  and more...

=back

=head1 SYNOPSIS

 Follow example show session capabilities, when WebTools is configured with 
 Flat file session support(default):

 <?perl 
    
    $sid = session_start();
    
    %h = read_hash('myhash');
    
    if($h{'city'} ne "Pleven")
      {
       print "<B>New session started!</B>";
       %h = (city=>"Pleven",country=>"Bulgaria");
       $reg_data = register_var('hash','myhash',%h);
       # $reg_data .= register_var('scalar','scl_name',$cnt);
       # $reg_data .= register_var('array',''arrname',@arr);
       session_register($reg_data);
      }
    else
      {
       print "Current session is: <B>$sid</B> <BR> and registrated data are:<BR>";
       print "Country: <B>".$h{'country'}."</B><BR>";
       print "City: <B>".$h{'city'}."</B><BR>";
       session_destroy();
       print "Session Destroyed!";
      }
    Header(type=>'content',val=>'text/html; charset=Windows-1251');
    # SURPRISE: We send header after html data??? (Is Php capable of this? ;-)
 ?>
 
 Above code can be saved in 'htmls' directory under 'test.whtml' file name and you can
 run it in browser location with follow line:
 http://your_host.com/cgi-bin/webtools/process.cgi?file=test.whtml


 
 Code below show how easy is to send e-mails with WebTools
 (Don't forget to set $debug_mail = 'off' in config.pl)
 <?perl 
 
    require 'mail.pl';
    
    $to   = 'some@where.com';
    $from = 'me@myhost.com';
    $subject = 'Test';
    $body = 'Hello there!';
    
    $orginal_filename = $uploaded_original_file_names{'myupload'};
    # 'myupload' is name of input field in html form.
    
    $fn = $uploaded_files{'myupload'};
    
    set_mail_attachment($orginal_filename,$fn);
    
    send_mail($from,$to,$subject,$body);
    print 'Mail sent!';
 ?>

 Above code can be saved in 'htmls' directory under 'mail.whtml' file name and you can
 run it in browser location with follow line:
 http://your_host.com/cgi-bin/webtools/process.cgi?file=mail.whtml
 

=over 4

=item Specifications and examples

=back

 Please read HELP.doc and see all examples in docs/examples directory

=head1 AUTHOR

 Julian Lishev - Bulgaria,Sofia
 e-mail: julian@proscriptum.com

=cut