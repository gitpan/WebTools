use lib '../../conf';
require 'config.pl';
require "../../drivers/db_flat.pl";

###################################################
#!!! CONFIGURE "config.pl" BEFORE RUN THAT FILE !!!
#!!! Update: user,password,database and tables  !!!
###################################################

$admin_user = 'admin';             # !!!EDIT!!!
$admin_pass = 'adminpassword';     # !!!EDIT!!!

 $dbh = sql_connect();
 $tab = << "TERMI";
 $sql_sessions_table (
        ID LONG,
        S_ID VARCHAR(45),
        IP VARCHAR(20),
        EXPIRE INT,
        FLAG CHAR(1),
        DATA VARCHAR(65535)
        )
TERMI
 sql_create_db($tab,$dbh);
$tab = << "TERMI";
 $sql_user_table (
        ID LONG,
        USER VARCHAR(30),
        PASSWORD VARCHAR(30),
        DATA VARCHAR(65535)
        )
TERMI
 sql_create_db($tab,$dbh);

sql_query("insert into $sql_user_table values(MAXVAL('ID|$sql_user_table'),'$admin_user','$admin_pass','');",$dbh);