#####################################################################
#  ###   ###     ###   ####   #####  #   #  #####  ####             #
#  #  #  #  #    #  #  #   #    #    #   #  #      #   #            #
#  #  #  ####    #  #  ####     #    #   #  #####  ####             #
#  #  #  #  #    #  #  #  #     #     # #   #      #  #             #
#  ###   ###     ###   #  ##  #####    #    #####  #  ##            #
#####################################################################
#  DB DRIVER FOR MySQL
#####################################################################
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################

$usystem_database_handle = undef;

eval 'use Mysql;';
if($@ ne '')
 {
  print "<br><font color='red'><h3>Error: MySQL module was not installed on your server!</h3></font>";
  exit;
 }

sub DB_OnExit
   {
    my ($system_database_handle) = @_;
    undef($system_database_handle);
    return(1);
   }
sub hideerror 
     {
      ClearBuffer();
      flush_print();
      select(STDOUT);
      my $t = tied(*SESSIONSTDOUT);
      $t->reset;
      print "<br><font color='red'><h2>Error: Can`t connect to MySQL database!</h2></font>";
      if($debugging =~ m/^on$/i)
        {
         print "<BR><font color='red'><h3>Debug mode: ON<BR>Error: ".Mysql->errmsg."</h3></font><BR>";
        }
      print "<font color='green' size=2>Please think over follow things at all...</font>";
      print "<br><font color='green' size=2> - What is your DB name, User name and password?</font>";
      print "<br><BR><font color='black'><h3>Please be nice and send e-mail to: $support_email </h3></font>";
      exit;
     }
sub sql_connect   # No params needed!
    {
     if($#_ == -1)
      {
       $oldh = $SIG{'__WARN__'};
       $SIG{'__WARN__'} = "hideerror";
       my $port = $sql_port eq '' ? '' : ';port='.$sql_port;
       my $OurSQL = Mysql->connect($sql_host.$port,$sql_database_sessions,$sql_user,$sql_pass);
       $SIG{'__WARN__'} = $oldh;
       $system_database_handle = $OurSQL;   # That is current opened DB Handler!
       return($OurSQL);
      }
     else    # ($host,$database,$user,$pass,[$port])
      {
       my ($host,$database,$user,$pass,$port) = @_;
       $port = $port || 3306;
       $host = $host || 'localhost';
       $user = $user || $sql_user;

       $oldh = $SIG{'__WARN__'};
       $SIG{'__WARN__'} = "hideerror";
       my $port = $port eq '' ? '' : ';port='.$port;
       my $uOurSQL = Mysql->connect($host.$port,$database,$user,$pass);
       $SIG{'__WARN__'} = $oldh;
       $usystem_database_handle = $uOurSQL;   # That is current opened DB Handler!
       return($uOurSQL);
      }
    }
sub test_connect
   {
     $oldh = $SIG{'__WARN__'};
     $SIG{'__WARN__'} = '';
     my $port = $sql_port eq '' ? '' : ';port='.$sql_port;
     my $OurSQL = Mysql->connect($sql_host.$port,$sql_database_sessions,$sql_user,$sql_pass) or return(0);
     $SIG{'__WARN__'} = $oldh;
     $system_database_handle = $OurSQL;   # That is current opened DB Handler!
     return($OurSQL);
   }
sub sql_disconnect # Only db handler is required!
   {
    my ($DBH) = @_;
    undef($DBH);
    return (1);
   }
sub sql_query   # ($query,$db_handler)
    {
     my ($q,$DBH) = @_;
     $q = sql_unsupported_types($q,$DBH);
     return ($DBH->query($q));   
    }
sub sql_fetchrow    # ($result_handler)
    {
     my ($resdb) = @_;
     if($resdb)
      {
       my @arr = $resdb->fetchrow;
       return(@arr);
      }
     return(0);
    }
sub sql_affected_rows   # ($result_handler)
    {    
     my ($resdb) = @_;
     if($resdb)
      {
       my $number = $resdb->affectedrows;
       return($number);
      }
     return(0);
    }
sub sql_inserted_id   # ($result_handler)
    {    
     my ($resdb) = @_;
     if($resdb)
      {
       my $number = $resdb->insertid;
       return($number);
      }
     return(0);
    }    
sub sql_create_db   # ($db_name,$db_handler)
    {    
     my ($db,$DBH) = @_;
     my $r = $DBH->createdb($db);
     return($r);
    }        
sub sql_drop_db   # ($db_name,$db_handler)
    {    
     my ($db,$DBH) = @_;
     my $r = $DBH->dropdb($db);
     return($r);
    } 
sub sql_select_db   # ($db_name,$db_handler)
    {    
     my ($db,$DBH) = @_;
     my $r = $DBH->selectdb($db);
     return($r);
    }
sub sql_num_fields   # ($result_handler)
    {    
     my ($resdb) = @_;
     if($resdb)
      {
       my $number = $resdb->numfields;
       return($number);
      }
     return(0);
    }
sub sql_num_rows   # ($result_handler)
    {    
     my ($resdb) = @_;
     if($resdb)
      {
       my $number = $resdb->numrows;
       return($number);
      }
     return(0);
    }

sub sql_data_seek
 {
  my ($row,$res) = @_;
  my $r = $res->dataseek($row);
  return($r);
 }
sub sql_errmsg
{
  my ($dbh) = @_;
  return(Mysql->errmsg);
}

sub sql_errno
{
  my ($dbh) = @_;
  return(Mysql->err);
}
sub sql_quote
{
 my ($unquoted_string,$dbh) = @_;
 return($dbh->quote($unquoted_string));
}
sub sql_unsupported_types
{
 my ($q,$DBH) = @_;
 while ($q =~ m/MAXVAL( *?)\(.*?\)/si)
    {
      $access_local_id_counter++;
      my $mtime = int(time());                                # It's realy bad way to make new unique IDs but...
      if($mtime < 900000000) {$mtime = $mtime + 1000000000;}  # Add more life for our ID :)
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
 my @my_array;
 if($sess_force_flat eq 'off') ###DB###
 {
  my $er = sql_query("delete from $sql_sessions_table where EXPIRE < NOW();",$dbh);
  if ($er eq undef) { return(0); }
 }
 else
 {
  ###FLAT###
  remove_SF_OldSessions($tmp.'/',time()-$sys_time_for_flat_sess);
 }
 return(1);
}
sub session_expire_update
{
 my ($dbh) = @_;
 my $i_id;
 my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
 my $r_q = '';
 if($sess_force_flat eq 'off') ###DB###
 {
  if($ip_restrict_mode =~ m/^on$/i)
    {
     $r_q = " and IP = \'$ip\'";    # Restrict session on IP!
    }
  my $r = sql_query("update $sql_sessions_table set EXPIRE = DATE_ADD(NOW(),interval $sess_time $sess_datetype) where S_ID = \'$sys_local_sess_id\'".$r_q,$dbh);
  if ($r eq undef) { return(0);}
 }
 else
 {
  ###FLAT###
  return(update_SF_File($tmp.'/',$sys_local_sess_id));
 }
 return (1);
}
sub insert_sessions_row   # ($session_id,$db_handler)
{
  my ($dbh) = @_;
  my $sid = $sys_local_sess_id;
  my $ip = $ENV{'REMOTE_ADDR'}; # Get remote IP address
  if($sess_force_flat eq 'off') ###DB###
  {
   my $q = "insert into $sql_sessions_table values(NULL,\'$sid\',\'$ip\',DATE_ADD(NOW(),interval $sess_time $sess_datetype),'0','');";
   my $res = sql_query($q,$dbh);
   if ($res ne undef)
     {
      return(1);
     }
  }
  else
  {
   ###FLAT###
   write_SF_File($tmp.'/',$sid,'');
   return(1);
  }
  return(0);
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
 my ($user,$pass,$data,$dbh) = @_;
 $user = sql_quote($user,$dbh);
 $pass = sql_quote($pass,$dbh);
 $data = sql_quote($data,$dbh);
 my $q = "insert into $sql_user_table values(NULL,$user,password($pass),$data);";
 my $res = sql_query($q,$dbh);
 if (($res ne undef) and (sql_affected_rows($res) > 0))
   {
    return(1);
   }
 return(0);
}
sub SignInUser
{
 my ($user,$pass,$dbh) = @_;
 $user = sql_quote($user,$dbh);
 $pass = sql_quote($pass,$dbh);
 $data = sql_quote($data,$dbh);
 my $q = "select ID,DATA from $sql_user_table where USER=$user and PASSWORD=password($pass);";
 my $res = sql_query($q,$dbh);
 if ($res eq undef)
   {
    return((undef,undef));
   }
 my ($ID,$DATA) = sql_fetchrow($res);
 if ($ID eq '') { return((undef,undef)); }
 return(($ID,$DATA));
}
1;