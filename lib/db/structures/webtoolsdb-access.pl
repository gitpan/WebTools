use lib '../../conf/';
require '../../conf/config.pl';
require "../../drivers/db_access.pl";

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
        DATA MEMO
        )
TERMI
 sql_create_db($tab,$dbh);
$tab = << "TERMI";
 $sql_user_table (
        ID LONG,
        USER VARCHAR(30),
        PASSWORD VARCHAR(30),
        DATA MEMO
        )
TERMI
 sql_create_db($tab,$dbh);

sql_query("insert into $sql_user_table values(NULL,'$admin_user','$admin_pass','');",$dbh);

# NOTE:  "ID" fields must be of type "AutoNumber"