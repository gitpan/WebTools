#####################################################################
#  ###   ###     ###   ####   #####  #   #  #####  ####             #
#  #  #  #  #    #  #  #   #    #    #   #  #      #   #            #
#  #  #  ####    #  #  ####     #    #   #  #####  ####             #
#  #  #  #  #    #  #  #  #     #     # #   #      #  #             #
#  ###   ###     ###   #  ##  #####    #    #####  #  ##            #
#####################################################################
#  DB DRIVER FOR Access
#####################################################################
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################

$usystem_database_handle = undef;
my $access_local_id_counter = 0;
my $db_access_read_size_limit = 1048576;   # Maximum bytes per db read (1MB)

eval 'use DBI;';
if($@ ne '')
 {
  print "<br><font color='red'><h3>Error: DBI module was not installed on your server!</h3></font>";
  exit;
 }
eval 'use DBD::ODBC;';
if($@ ne '')
 {
  print "<br><font color='red'><h3>Error: DBD::ODBC module was not installed on your server!</h3></font>";
  exit;
 }
 
sub DB_OnExit
   {
    my ($system_database_handle) = @_;
    sql_disconnect($system_database_handle);
    undef($system_database_handle);
    return(1);
   }
sub hideerror 
     {
      eval
       {
        ClearBuffer();
        flush_print();
        select(STDOUT);
        my $t = tied(*SESSIONSTDOUT);
        $t->reset;
       };
      print "<br><font color='red'><h2>Error: Can`t connect to Access database!</h2></font>";
      if($debugging =~ m/^on$/i)
        {
         print "<BR><font color='red'><h3>Debug mode: ON<BR>Error: ".$DBI::errstr."</h3></font><BR>";
        }
      print "<font color='green' size=2>Please think over follow things at all...</font>";
      print "<br><font color='green' size=2> - What is your DB name, User name and password?</font>";
      print "<br><font color='green' size=2> - Where is DB located and how it is linked?</font>";
      print "<br><font color='green' size=2> - There is ODBC and is it correct setup it?</font>";
      print "<br><font color='green' size=2> - Is Apache has a correct user (permission to access DB)?</font>";
      print "<br><BR><font color='black'><h3>Please be nice and send e-mail to: $support_email </h3></font>";
      exit;
     }
sub sql_connect   # No params needed!
    {
     if($#_ == -1)
      {
       my $oldslcthnd = select(STDOUT);
       $oldh = $SIG{'__WARN__'};
       $SIG{'__WARN__'} = "hideerror";
       my $OurSQL = DBI->connect("DBI:ODBC:"."$sql_database_sessions",$sql_user,$sql_pass,{RaiseError => 0, PrintError => 1, AutoCommit => 1}) or hideerror();
       $OurSQL->{LongReadLen} = $db_access_read_size_limit;
       $SIG{'__WARN__'} = $oldh;
       $system_database_handle = $OurSQL;   # That is current opened DB Handler!
       select($oldslcthnd);
       return($OurSQL);     
      }
     else    # ($host,$database,$user,$pass,[$port])
      {
       my ($host,$database,$user,$pass,$port) = @_;
       $database = $database || $sql_database_sessions;
       $user = $user || $sql_user;
 
       $oldh = $SIG{'__WARN__'};
       $SIG{'__WARN__'} = "hideerror";
       my $uOurSQL = DBI->connect("DBI:ODBC:"."$database",$user,$pass,{RaiseError => 0, PrintError => 1, AutoCommit => 1}) or hideerror();
       $SIG{'__WARN__'} = $oldh;
       $usystem_database_handle = $uOurSQL;   # That is current opened DB Handler!
       return($uOurSQL);
      }
    }
sub test_connect
   {
     my $oldslcthnd = select(STDOUT);
     $oldh = $SIG{'__WARN__'};
     $SIG{'__WARN__'} = '';
     my $OurSQL = DBI->connect("DBI:ODBC:"."$sql_database_sessions",$sql_user,$sql_pass,{RaiseError => 0, PrintError => 1, AutoCommit => 1}) or return(0);
     $OurSQL->{LongReadLen} = $db_access_read_size_limit;
     $SIG{'__WARN__'} = $oldh;
     $system_database_handle = $OurSQL;   # That is current opened DB Handler!
     select($oldslcthnd);
     return($OurSQL);     
   }
sub sql_connect2
    {
     my ($db) = @_;
     my $oldslcthnd = select(STDOUT);
     $oldh = $SIG{'__WARN__'};
     $SIG{'__WARN__'} = "hideerror";
     my $OurSQL = DBI->connect("DBI:ODBC:"."$db",$sql_user,$sql_pass) or hideerror();
     $OurSQL->{LongReadLen} = $db_access_read_size_limit;
     $SIG{'__WARN__'} = $oldh;
     $system_database_handle = $OurSQL;   # That is current opened DB Handler!
     select($oldslcthnd);
     return($OurSQL);     
    }
sub sql_disconnect # Only db handler is required!
   {
    my ($DBH) = @_;
    $DBH->disconnect();
    undef($DBH);
    return (1);
   }
sub sql_query   # ($query,$db_handler)
    {
     my ($q,$DBH) = @_;
     $q =~ s/;$//s;
     $q = sql_unsupported_types($q,$DBH);
     my $hSt = $DBH->prepare($q);
     if($hSt)
      {
       $hSt->execute();
       #$hSt->finish();
       return ($hSt);
      }
     else {return $DBH->errstr();}
    }
sub sql_fetchrow    # ($result_handler)
    {
     my ($resdb) = @_;
     my $raRes = $resdb->fetchrow_arrayref();
     my @arr = @$raRes;
     return(@arr);
    }
sub sql_affected_rows   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = $resdb->rows;
     return($number);
    }
sub sql_inserted_id   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = undef;
     return($number);
    }    
sub sql_create_db   # ($table_description,$db_handler) -> Not DB! This is TABLE!
    {    
     my ($db,$DBH) = @_;
     $db =~ s/;$//s;
     return($DBH->do('CREATE TABLE '.$db));
    }        
sub sql_drop_db   # ($db_name,$db_handler) -> Not DB! This is TABLE!
    {    
     my ($db,$DBH) = @_;
     $db =~ s/;$//s;
     return($DBH->do('DROP TABLE '.$db));
    } 
sub sql_select_db
 {
    my($db, $self) = @_;
    my $dbh = sql_connect('localhost',$db,$sql_user, $sql_pass, 0, '');
    if (!$dbh) 
     {
      return(undef);
     }
    else
     {
      if ($self) 
        {
	 sql_disconnect($self);
   	}
     }
    return($dbh);
 }
sub sql_num_fields   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = $resdb->{NUM_OF_FIELDS};
     return($number);
    }
sub sql_num_rows   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = sql_affected_rows($resdb);
     return($number);
    }
sub sql_insert_id
{
  my ($res) = @_;
  return(-1);
}
sub sql_errmsg
{
  my ($dbh) = @_;
  return($DBI::errstr);
}

sub sql_errno
{
  my ($dbh) = @_;
  return($DBI::err);
}
sub sql_quote
{
 my ($unquoted_string,$dbh) = @_;
 my $str = $dbh->quote($unquoted_string);
 return($str);

}
sub sql_unsupported_types
{
 my ($q,$DBH) = @_;
 while ($q =~ m/MAXVAL( *?)\(.*?\)/si)
    {
      $access_local_id_counter++;
      my $mtime = int(time());                                # It's realy bad way to make new unique IDs but...
      if($mtime < 900000000) {$mtime = $mtime + 1000000000;}  # add more life for our ID :)
      $q =~ s/MAXVAL( *?)\(.*?\)/$mtime/si;
    }
 return($q);
}
#####################################################################
# Session Support Functions
#####################################################################
sub session_clear_expired
{
 my ($dbh) = @_;
 my $i_id;
 my $ctime = scalar(time());
 my @my_array;
 if($sess_force_flat eq 'off') ###DB###
 {
  my $er = sql_query("delete from $sql_sessions_table where EXPIRE < $ctime;",$dbh);
  if ($er eq undef) { return(0); }
 }
 else
 {
  ###FLAT###
  remove_SF_OldSessions($tmp,time()-$sys_time_for_flat_sess);
 }
 return(1);
}
sub session_expire_update
{
 my ($dbh) = @_;
 my %calmin  = ('second',1,'minute',60,'hour',3600,'day',86400,'month',2678400,'year',31536000);
 my %globmin = ('s',1,'m',60,'h',3600,'d',86400,'M',2678400,'y',31536000);
 my $inter = $sess_time * $calmin{$sess_datetype};
 $inter += time();
 my $i_id;
 my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
 my $r_q = '';
if($sess_force_flat eq 'off') ###DB###
 {
  if($ip_restrict_mode =~ m/^on$/i)
    {
     $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
    }
  my $r = sql_query("update $sql_sessions_table set EXPIRE = $inter where S_ID = \'$sys_local_sess_id\'".$r_q,$dbh);
  if ($r eq undef) { return(0);}
 }
 else
 {
  ###FLAT###
  return(update_SF_File($tmp,$sys_local_sess_id));
 }
 return (1);
}
sub insert_sessions_row   # ($session_id,$db_handler)
{
  my ($dbh) = @_;
  my %calmin  = ('second',1,'minute',60,'hour',3600,'day',86400,'month',2678400,'year',31536000);
  my %globmin = ('s',1,'m',60,'h',3600,'d',86400,'M',2678400,'y',31536000);
  my $inter = $sess_time * $calmin{$sess_datetype};
  $inter += time();
  my $sid = $sys_local_sess_id;
  my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
  if($sess_force_flat eq 'off') ###DB###
  {
   my $q = "INSERT INTO $sql_sessions_table(S_ID,IP,EXPIRE,FLAG,DATA) VALUES(?,?,?,?,?);";
   my $res = $dbh->do($q,undef,$sid,$ip,$inter,0,'');

   if ($res eq '1')
     {
      return(1);
     }
  }
  else
  {
   ###FLAT###
   write_SF_File($tmp,$sid,'');
   return(1);
  }
  return(0);
}
sub sql_data_seek
{
 my ($row,$res) = @_;
 return(-1);
}
sub DB_OnDestroy
 {
   return(1);        # Something like Commit!
 }
#####################################################################
# USER DEFINED FUNCTIONS
#####################################################################
sub SignUpUser
{
 my ($user,$pass,$data,$active,$fname,$lname,$email,$dbh) = @_;
 my $ut = "SELECT USER FROM $sql_user_table WHERE USER=?";
 my $q = "INSERT INTO $sql_user_table(USER,PASSWORD,ACTIVE,DATA,CREATED,FNAME,LNAME,EMAIL) VALUES(?,?,?,?,?,?,?,?);";
 $active = uc($active);

 my $rut = $dbh->prepare($ut);
 $rut->execute($user);

 my @arr = ();
 eval {@arr = sql_fetchrow($rut);};
 if ($arr[0] ne '') { return(0);}
 else
  {
   my $res = $dbh->do($q,undef,$user,$pass,$active,$data,time(),$fname,$lname,$email);
   if ($res eq '1')
     {
       return(1);
     }
   return(0);
  } 
 return(0); 
}
sub SignInUser
{
 my ($user,$pass,$dbh) = @_;
 $user = sql_quote($user,$dbh);
 $pass = sql_quote($pass,$dbh);
 my $q = "SELECT ID,DATA FROM $sql_user_table WHERE USER=$user and PASSWORD=$pass and ACTIVE=\'Y\';";
 my $res = sql_query($q,$dbh);
 if ($res eq undef)
   {
    return((undef,undef));
   }
 my ($ID,$DATA) = sql_fetchrow($res);
 if ($ID eq '') {return((undef,undef)); }
 return(($ID,$DATA));
}

1;