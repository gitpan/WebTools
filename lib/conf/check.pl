#####################################################
# Helper script checking functionallity of
# package and self configuration.
# (internally called by "config.pl")
#####################################################
# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.
#####################################################

sub check_configuration
{
 if ($check_module_functions eq 'on')   # Script now working only in debug mode!
  {
   # Eval code for speed! (this code will be compiled only if need)
   $eval_this_code = << 'EVAL_TERMINATOR';
   print STDOUT "Content-type: text/html\n\n";
   print STDOUT '<font face="Verdana, Arial" size=2 color="#202070">';
   print STDOUT '<center><H3><p style="color:red">Test Mode</p></H3></center>';
   print STDOUT "<B>Your variable ".'<span style="color:red">$check_module_functions</span>'.
                " (<span style='color:red'>in config.pl</span>) is turned 'on'<BR>";
   print STDOUT "...force CHECKING mode<BR>";
   print STDOUT '<font face="Verdana, Arial" size=1>';
   print STDOUT "(to turn off this check and script run normal, please set variable to 'off'!</font><BR><BR>";
   print STDOUT "<HR><U><span style='color:red'>Checking your paths</span></U>:<BR><BR>";
   
   print STDOUT "<LI>Driver path";
   if(-e $driver_path) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<LI>Library path";
   if(-e $library_path) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<LI>DataBase path";
   if(-e $db_path) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<LI>Test DB Engine";
   
   if(($db_support eq 'db_mysql') or ($db_support eq 'db_access') or ($db_support eq 'db_flat'))
    {
     require $driver_path.$db_support.'.pl';
     my $dbh = test_connect();
     my $q = "SELECT * FROM $sql_user_table";
     my @ar = ();
     my $r = '';
     if($dbh)
      {
       $r = sql_query($q,$dbh);
       if($r) {@ar = sql_fetchrow($r);}
       if($#ar > 0) {print STDOUT "...looks good"; }
       else {ErrorMessage("...<span style='background:red'>NOT WORK!</span> DB Engine sad: ".sql_errmsg()."<BR>");}
      }
     else {ErrorMessage("...<span style='background:red'>NOT WORK!</span> Error: Can't connect!<BR>");}
    }
   else {print STDOUT "...can't define (not standart DB driver?)"; }
   
   print STDOUT "<LI> Mail path";
   my $result = DirectoryRights($mailsender_path,3); # Read/Write
   if($result eq 'ok') { print STDOUT "...ok"; }
     else {ErrorMessage("...<span style='background:red'>".$result."...</span><BR>");}
      
   print STDOUT "<LI> Xreader path";
   if(-e $xreader_path) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<LI> Perl/HTML path";
   if(-e $perl_html_dir) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<LI> Web server htdocs (root) path";
   if(-e $apacheshtdocs) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<LI> Temp path";  # Read/Write
   my $result = DirectoryRights($tmp,3);
   if($result eq 'ok') { print STDOUT "...ok"; }
     else {ErrorMessage("...<span style='background:red'>".$result."...</span><BR>");}

   print STDOUT "<HR><U><span style='color:red'>Checking your external programs</span></U>:<BR><BR>";
   
   print STDOUT "<LI> Sendmail";
   if(-e $sendmail) { print STDOUT "...ok"; }
   else {ErrorMessage("...<span style='background:red'>NOT EXISTS...</span><BR>");}
   
   print STDOUT "<HR><U><span style='color:red'>Info</span></U>:<BR><BR>";
   
   print STDOUT "<LI> Name of project:";
   print STDOUT " $projectname";
   
   print STDOUT "<LI> Name of db driver:";
   if($db_support eq 'db_mysql' or $db_support eq 'db_access' or $db_support eq 'db_excel' or $db_support eq 'db_flat')
    {
     print STDOUT " $db_support";
    }
   else
    {
     print STDOUT " $db_support (that is not standart db driver...please check it!)";
    }
      
   print STDOUT "<LI> Name of database:";
   print STDOUT " $sql_database_sessions";
   
   print STDOUT "<LI> Session time is:";
   print STDOUT " $sess_time $sys_conf_d";
   
   print STDOUT "<LI> Session cookie expiration:";
   if($sess_cookie eq 'sesstime')
    {
     print STDOUT " when session expire! (same as session time)";
    }
   else
    {
     print STDOUT " when browser is closed! (Browser side)";    
    }
   
   print STDOUT "<LI> Name of session ID:";
   print STDOUT " $l_sid";
   
   print STDOUT "<LI> Cookie/Get/Post priority:";
   if($cpg_priority eq 'cookie')
    {
     print STDOUT " cookie has higher priority";
    }
   else
    {
     print STDOUT " get/post has higher priority";
    }
   
   print STDOUT "<LI> Session support via:";
   if($sess_cpg eq 'cookie')
    {
     print STDOUT "  cookies";
    }
   else
    {
     print STDOUT " get/post(links/forms)";
    }

   print STDOUT "<LI> Force flat files with sessions:";
   if($sess_force_flat eq 'on')
    {
     print STDOUT "  ON (store session's data in flat files)";
    }
   else
    {
     print STDOUT " OFF (store session's data in database)";
    }

   print STDOUT "<LI> Maximum size of data via POST method:";
   print STDOUT " $cgi_lib_maxdata bytes";   
   
   print STDOUT "<LI> Multipart support...";
   if($cgi_lib_forbid_mulipart eq 'off')
    {
     print STDOUT " on";
    }
   else
    {
     print STDOUT " off (multipart spam protected)";
    }
   
   print STDOUT "<LI> Restrict sessions by IP...";
   if($ip_restrict_mode =~ m/^on$/is)
    {
     print STDOUT " on";
    }
   else
    {
     print STDOUT " off";
    }
   
   print STDOUT "<LI> Restrict script execution by IP...";
   if($run_restrict_mode =~ m/^on$/is)
    {
     print STDOUT " on";
    }
   else
    {
     print STDOUT " off";
    }
   
   print STDOUT "<LI> Printing mode...";
   if($var_printing_mode =~ m/^buffered$/is)
    {
     print STDOUT " buffered";
    }
   else
    {
     print STDOUT " non buffered";
    }
   
   print STDOUT "<LI> Searching row: ";
   my $trow;
   foreach $trow (@treat_htmls_ext)
    {
     print $trow."&nbsp;&nbsp;";
    }
   
   print STDOUT "<LI> Debugging mode is";
   print STDOUT "...$debugging";

   print STDOUT '</B></font><BR>';
   
EVAL_TERMINATOR

   eval $eval_this_code;
   exit;
  }
}

sub DirectoryRights
 {
  my ($path,$mask) = @_;
  my $result = 0;
  #  mask can be: 1-Read test; 2-Write test;
  if (-e $path)
   {
    if ($mask & 1)
      {
       if(!Check_R($path)) {return('Directory is NOT READABLE');}
      }
    else
      {
       if(Check_R($path)) {return('WARNNING: Directory is readable, that is INSECURE!!!');}
      }
    if ($mask & 2)
      {
       if(!Check_W($path)) {return('Can NOT WRITE in directory');}
      }
    else
      {
       if(Check_W($path)) {return('WARNNING: Directory is writeable, that is INSECURE!!!');}
      }
   }
  else
    {
     {return('Directory NOT EXISTS');}
    }
  return('ok');
 }

sub Check_R
{
 my ($path) = @_;
 opendir(FDIR,$path) or return(0);
 closedir(FDIR);
 return(1);
}

sub Check_W
{
 my ($path) = @_;
 if(!($path =~ m/.*\/$/s)) {$path .= '/';}
 $f = $path.'check_pl_file_'.rand()*1000;
 open(FILE,'>'.$f) or return(0);
 print (FILE 'TEST') or return(0);
 close(FILE);
 unlink($f);
 return(1);
}

sub ErrorMessage
 {
    print STDOUT shift(@_);
    print STDOUT "<BLOCKQUOTE>Please check your package and config.pl (this) file!</BLOCKQUOTE><BR>";
 }

1;