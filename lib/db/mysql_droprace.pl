##############################
# Don not start it via WEB!!!
# Set permissions to: 000 :-)
##############################
#!/usr/bin/perl

use Mysql;

  $a = $perl_html_dir.'config.ini';
  if (open(FFL_CFG,$a))
   {
    undef $/;
    $data = <FFL_CFG>;
    $/ = "\n";
    close FFL_CFG;
    $data =~ s/<(.*?)> *?= *?'(.*?)';/
    do {
        $cfghash{$1} = $2;
       };
    /isge;
    $loading_cfg_fail = 0;
   }
  else
   {
     $loading_cfg_fail = 1;
   }
 ################################################################
 # Loading values from 'config.ini'
 ################################################################ 
 if(!$loading_cfg_fail)
  {
   $sql_host = $cfghash{'host'};
   $sql_user = $cfghash{'user'};
   $sql_pass = $cfghash{'password'};
   $Mysql::QUIET = $cfghash{'mysqlbequiet'};
   $sql_database_sessions = $cfghash{'database'};
   $sql_sessions_table = $cfghash{'sesstable'};
 
   $l_sid = $cfghash{'sesslabel'};
   $tmp = $cfghash{'tempdir'};
   $rand_sid_length = $cfghash{'sid_length'};
   $sess_time = $cfghash{'sesstime'};
   $wait_for_open = $cfghash{'wait'};
   $wait_attempt = $cfghash{'attempts'};
   $uni_sep = $cfghash{'separator'};
   $uni_sep_t = $cfghash{'separator_s'};
   $uni_gr_sep = $cfghash{'separator_gr'};
   $uni_gr_sep_t = $cfghash{'separator_gr_s'};
   $charset = $cfghash{'charset'};
   $sendmail = $cfghash{'sendmail'};
   $debugging = $cfghash{'debbuging'};
   $perl_html_dir = $cfghash{'htmldir'};
   $sess_cpg = $cfghash{'CPG'};
   $sess_datetype = $cfghash{'datetype'};
   $sess_cookie = $cfghash{'cookie'};
   $sesstimead = $cfghash{'sesstimead'};
   $sql_user_table = $cfghash{'demo_users'};
   $apacheshtdocs = $cfghash{'apacheshtdocs'};
  }

print "That program will destroy all data into database!!!\n";
print "Please press 'Y' key If you know what you doing!\n";
print "> ";
$key = <STDIN>;
chomp($key);
if(($key ne 'Y') and ($key ne 'y'))
 {
  print "\nExit... \n";
  exit;
 } 
print "Destroy in process...\n";
$dbh =  sql_connect();

$q = "show tables;";
my $r = sql_query($q,$dbh);

while(my (@msv) = $r->fetchrow($r))
     {
      $q = "drop table $msv[0]\;";
      print "$q\n";
      my $p = sql_query($q,$dbh);
     }
print "Done...\n";

#################################################################
sub hideerror 
     {
      $print_flush_buffer = '';
      print "<br><font color='red'><h2>Error: Can`t connect to database!</h2></font>";
      exit;
     }
sub sql_connect   # No params needed!
    {
     $oldh = $SIG{'__WARN__'};
     $SIG{'__WARN__'} = "hideerror";
     my $OurSQL = Mysql->connect($sql_host,$sql_database_sessions,$sql_user,$sql_pass);
     $SIG{'__WARN__'} = $oldh;
     return($OurSQL);
    }
sub sql_query   # ($query,$db_handler)
    {
     my ($q,$DBH) = @_;
     return ($DBH->query($q));   
    }
sub sql_fetchrow    # ($result_handler)
    {
     my ($resdb) = @_;
     my @arr = $resdb->fetchrow;
     return(@arr);
    }
sub sql_affected_rows   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = $resdb->affectedrows;
     return($number);
    }
sub sql_inserted_id   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = $resdb->insertid;
     return($number);
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
     my $number = $resdb->numfields;
     return($number);
    }
sub sql_num_rows   # ($result_handler)
    {    
     my ($resdb) = @_;
     my $number = $resdb->numrows;
     return($number);
    }
sub sql_quote
{
 my ($unquoted_string,$dbh) = @_;
 return($dbh->quote($unquoted_string));
}
############################################################################