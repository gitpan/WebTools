###################################################################
# Configuration file for "Web Tools" ver 1.14
# Please edit here, don’t do that in Perl scripts!
###################################################################

#[Name_Of_Project]
$projectname = 'webtools';   # Name of project!

#[SQL]
$db_support = 'db_flat';     # Can be: db_mysql, db_access, db_flat
$sql_host = 'localhost';     # Script will connect to MySQL Server
$sql_port = '3306';          # Port of SQL server
$sql_user = 'user';          # using user
$sql_pass = 'pass';          # and password

#[DataBase]
$sql_database_sessions =  $projectname.'db';         # Database name (name some like project!!!)
$sql_sessions_table =  $projectname.'_sessions';     # Session table (name: project_sessions)!
$sql_user_table = $projectname.'_users';             # Contain all users (and admin too)

#[CHECK]
$check_module_functions = 'on';       # After first check, please turn this 'off'!

#[Secure]
$wait_attempt = '4';                  # Count of attempts when database is flocked
$wait_for_open = '2.0';               # Time between two attempts (in sec)
$sess_time = '2';                     # Expire time on session(2 hours)
$sys_conf_d = 'hour';                 # time dimenstion (lower case only) and can be:
                                      # second,minute,hour,day,month and year
$rand_sid_length = '16';              # Length of random SID string!
$sess_cookie = 'sesstime';            # 'sesstime'(i.e. expire after $sess_time) or
                                      # '0' (i.e. expire when user close browser)

$l_sid = 'sid';                       # Session ID label used by module

$cgi_lib_forbid_mulipart = 'off';     # If you want to protect yourself from multipart spam
                                      # turn this 'on' (you will be no longer able to use 
                                      # multipart forms)!
$cgi_lib_maxdata    = 4194304;        # maximum bytes to accept via POST (4MB)
$cgi_script_timeout = 120;            # Expiration time of script! (120 seconds default)
$ip_restrict_mode   = 'off';          # Set 'on' to restrict session on IP! If you get proxy
                                      # problems with restricted IPs, please set 'off' or use
                                      # proper function to set mode of this variable!
$run_restrict_mode  = 'off';          # Set 'on' to restrict external web user to your scripts.
                                      # If IP's of user not exists in DB/ips.pl WebTools will
                                      # close script immediately!
                                      
#[Debug]
$debugging = 'on';                    # Debugging mode
$debug_mail = 'on';                   # Show whether real mail must by send
                                      # or must by saved into mail directory!

#[Mail]
$sendmail = '/usr/sbin/sendmail';     # sendmail path

#[Other]
$charset = 'TYn5b0xzlQu7SVBh3sHJKL8mUIvcOPZ2aWytCMAwq1prEe4oiDFG6R9kjdgfNX';
                                           # Please mix well this chars
					   # to get higher security of your session ID :-)

$cpg_priority = 'cookie';                  # Show order of value fetching! There is 2 values: 'cookie' and 'get/post'.
                                           # 'cookie' means that cookie's variable has higher priority!
$sess_force_flat = 'on';                   # Session support via DB or via file! (possible values are: 'on' and 'off')

$support_email = 'support@your_host.com';  # Support e-mail
$var_printing_mode = 'buffered';           # Default output is buffered,
                                           # leave this variable empty if you need output
                                           # of your script to flush 
                                           # immediately!
@treat_htmls_ext = (                       # Order of html files location: Default, module first look for:
	            'whtml',               # "whtml","html","htm","cgihtml" and "cgi". If you specify in URL
	            'html',                # ...?file=env.html script will ignore extension and will look for
	            'htm',                 # file with extension orderd in @treat_htmls_ext array
	            'cgihtml',             # If you leave this array empty then no lookups will be made!
	            'cgi',                 # Please read carefull documentation (HELP.html) for additional info.
	           );
# Example:
# @treat_htmls_ext = (                     # If Apache return as plain text your "whtml" file in cgi-bin
#                     'whtml',             # directory, then you can rename your "whtml" file to "cgi"!
#     	              'cgihtml'            # So process.cgi will be able to handle your query:
#                     'html',              # ...?file=test.whtml despite that real name is test.cgi !
#                     'htm',
#                     'cgi',
#  	             );

#[PATHS]
$tmp = '/tmp/';                            # Temp directory
$driver_path = './drivers/';               # Driver`s path
$library_path = './libs/';                 # Librarie`s path
$db_path = './db/';                        # DB`s path
$mailsender_path = './mail/';              # Mail`s path
$xreader_path = './jhtml/';                # Path of xreader files(jhtml-s)
$perl_html_dir = './htmls/';               # Directory were peril’s html files are (/usr/local/apache/perlhtml/)
$apacheshtdocs = '/var/www/htdocs/';       # '/usr/local/apache/htdocs/'
$cgi_home_path = Get_CGI_Directory();      # Get webtools cgi-bin directory (exam: '/cgi-bin/webtools/')
					   # NOTE: This path is not absolute and is not an HTTP!!!
$http_home_path = '/webtools/';            # Please change this to your http path!

@use_addition_paths = ('./db/');  # Push paths in this array to force using of these
                                  # directories from Perl

###################################################################
# ------- DO NOT EDIT BELOW THIS LINE!!! -------
###################################################################

# 
# Determinate OS type
# 

unless ($sys_OS) 
 {
  unless ($sys_OS = $^O) 
     {
      require Config;
      $sys_OS = $Config::Config{'osname'};
     }
 }
if    ($sys_OS =~ /^MSWin/i){$sys_OS = 'WINDOWS';}
elsif ($sys_OS =~ /^VMS/i) {$sys_OS = 'VMS';}
elsif ($sys_OS =~ /^dos/i) {$sys_OS = 'DOS';}
elsif ($sys_OS =~ /^MacOS/i) {$sys_OS = 'MACINTOSH';}
elsif ($sys_OS =~ /^os2/i) {$sys_OS = 'OS2';}
elsif ($sys_OS =~ /^epoc/i) {$sys_OS = 'EPOC';}
else  {$sys_OS = 'UNIX'; }

$needs_binmode = $sys_OS=~/^(WINDOWS|DOS|OS2|MSWin)/;

# 
# The path separator is a slash, backslash or semicolon, depending
# on the paltform.
# 

$SL = {
       UNIX=>'/', OS2=>'\\', EPOC=>'/', 
       WINDOWS=>'\\', DOS=>'\\', MACINTOSH=>':', VMS=>'/'
      }->{$sys_OS};

# 
# Define the CRLF sequence.
# 

$sys_EBCDIC = "\t" ne "\011";
if ($sys_OS eq 'VMS') {$sys_CRLF = "\n";}
elsif ($sys_EBCDIC)   {$sys_CRLF= "\r\n";}
else {$sys_CRLF = "\015\012";}

$mysqlbequiet = '1';
%dts = ('second' => 's','minute' => 'm', 'hour' => 'h', 'day' => 'd', 'month' => 'M', 'year' => 'y');
%dts_flat = ('second' => 1,'minute' => 60, 'hour' => 3600, 'day' => 86400, 'month' => 2678400, 'year' => 31536000);
$sys_c_d_h = $dts{$sys_conf_d};
$sesstimead = '+'.$sess_time.$sys_c_d_h;
$sess_datetype = $sys_conf_d;
$sys_time_for_flat_sess = $dts_flat{$sys_conf_d} * $sess_time;
$uni_sep = '©';                            # Col separator
$uni_sep_t = '\©';                         # Col separator (slashed)
$uni_gr_sep = ':';                         # Row separator
$uni_gr_sep_t = '\:';                      # Row separator (slashed)
$uni_esc = '%';                            # Escape char
$config_path   = PathMaker('./conf/','../conf/');
$library_path  = PathMaker($library_path,'.'.$library_path);
$db_path       = PathMaker($db_path,'.'.$db_path);
$driver_path   = PathMaker($driver_path,'.'.$driver_path);
$xreader_path  = PathMaker($xreader_path,'.'.$xreader_path);
$perl_html_dir = PathMaker($perl_html_dir,'.'.$perl_html_dir);
$tmp =~ s/\/$//si;
foreach my $path (@use_addition_paths) { PathMaker($path,''); }

##########################################################################################
# This part check structure of script
# If $check_module_functions equal on 'true' then this check is performed always!!!
# If you have already checked structure please turn this feature off!!!
##########################################################################################
if ($check_module_functions eq 'on')
 {
  require 'check.pl';
  check_configuration();
 }

$loading_cfg_fail = 0;

sub PathMaker                 # Make paths to your base webtools files!
 {
  my $pth = (-e $_[0]) ? $_[0] : $_[1];
  if($_[0] =~ m/^(\\|\/)$/si) {return ('/');}
  if($_[0] ne '')
  {
    eval ("use lib \'$pth\';"); return($pth);
  }
  return ('');
 }
 
sub Get_CGI_Directory         
 {
  my $path =  $ENV{'SCRIPT_NAME'};
  if($path =~ m/^(.*?)\/process\.cgi/is)
   {
    return($path.'/');
   }
  return('');
 }
$sys_config_pl_loaded = 1;
1;