###################################################################
# Configuration file for "Web Tools"
# Please edit here, don’t do that in Perl scripts!
###################################################################

#[Name_Of_Project]
$projectname = 'webtools';        # Name of project!

#[SQL]
$db_support = 'db_flat';     # Can be: db_mysql, db_access, db_flat, i.e...
$sql_host = 'localhost';     # Script will connect to MySQL Server
$sql_port = '3306';          # Port of SQL server
$sql_user = 'user';          # using user
$sql_pass = 'pass';          # and password
$mysqlbequiet = '1';         # MySQL be QUIET?

#[DataBase]
$sql_database_sessions =  $projectname.'db';         # Database name (name some like project!!!). If need change it!
$sql_sessions_table =  $projectname.'_sessions';     # Session table (name: project_sessions)!
$sql_user_table = $projectname.'_users';             # Contain all users (and admin too)

#[CHECK]
$check_module_functions = 'on';       # After first check, please turn this 'off'!

#[Secure]
$wait_attempt = '4';                  # Count of attempts when database is flocked
$wait_for_open = '2.0';               # Time between two attempts (in sec)
$sess_time = '2';                     # Expire time on session: 60 minutes
%dts = ('second' => 's','minute' => 'm', 'hour' => 'h', 'day' => 'd', 'month' => 'M', 'year' => 'y'); # Do not edit!
%dts_flat = ('second' => 1,'minute' => 60, 'hour' => 3600, 'day' => 86400, 'month' => 2678400, 'year' => 31536000); # Do not edit!
$sys_conf_d = 'hour';                 # Same like previous but for cookie!
$sys_c_d_h = $dts{$sys_conf_d};       # s(econds) m(inutes) h(our) d(ay) now M(onths) y(ears) Do not edit!
$sesstimead = '+'.$sess_time.$sys_c_d_h; # Do not edit!
$sess_datetype = $sys_conf_d;         # Type of sess time dimension. Do not edit!
$sys_time_for_flat_sess = $dts_flat{$sys_conf_d} * $sess_time; # Do not edit!
$rand_sid_length = '16';              # Length of random SID string!
$sess_cookie = 'sesstime';            # 'sesstime' or other(i.e. expire when close browser)
$tmp = '/tmp';                        # Session directory 
$l_sid = 'sid';                       # Session ID label used by module
$referrer = '/';                      # Referrer pages (servers)
$cgi_lib_forbid_mulipart = 'off';     # If you want to protect yourself from multipart spam
                                      # turn this 'on' (you will be no longer able to use 
                                      # multipart forms)!
$cgi_lib_maxdata    = 1000000;        # maximum bytes to accept via POST (1MB)
$cgi_script_timeout = 120;            # Expiration time of script! (120 seconds default)
$ip_restrict_mode   = 'on';           # Set 'on' to restrict session on IP! If get proxy problems
                                      # with restricted IPs, please set 'off' or use proper
                                      # function to set mode of this variable!

#[Debug]
$debugging = 'on';                    # Debugging mode
$debug_mail = 'on';                   # Show whether real mail must by send
                                      # or must by saved into mail directory!

#[Mail]
$sendmail = '/usr/sbin/sendmail';     # sendmail path

#[Other]
$charset = 'WdgfNXytCMAwq1TYn5b0xzlQu7SVBmUIvcOPZ2aprEe4oiDFG6R9kjh3sHJKL8'; # Please mix well this chars
					   # to get higher security of your session ID :-)

$cpg_priority = 'cookie';                  # Show order of value fetching! There is 2 values: 'cookie' and 'get/post'.
                                           # 'cookie' means that cookie's variable has higher priority!
$sess_cpg = 'cookie';                      # Type of session support: (It can be 'cookie' or Session ID can be
                                           # moved by links or forms ('get/post')
$sess_force_flat = 'on';                   # Session support via DB or via file! (possible values are: 'on' and 'off')

$support_email = 'support@your_host.com';  # Support e-mail
$var_printing_mode = 'buffered';           # Default output is buffered,
                                           # leave this variable empty if you need output
                                           # of your script to flush 
                                           # immediately!
$uni_sep = '©';                            # Col separator
$uni_sep_t = '\©';                         # Col separator (slashed)
$uni_gr_sep = ':';                         # Row separator
$uni_gr_sep_t = '\:';                      # Row separator (slashed)
$uni_esc = '%';                            # Escape char
@treat_htmls_ext = (                       # Order of html files location: Default, module first look for:
	            'whtml',               # "html","htm","whtml" and "cgihtml". If you specify in URL
	            'html',                 # ...?file=env.html script will ignore extension and will look for
	            'htm',                # file with extension orderd in @treat_htmls_ext array
	            'cgihtml',             # If you leave this array empty then no lookups will be made!
	            'cgi',                 # Please read carefull documentation (Help.doc) for additional info.
	           );
# Example:
# @treat_htmls_ext = (                     # That mean that you can use in your applications
#                     'whtml',             # html extension but for security reasons you
#     	              'cgihtml'            # can name your real htmls files with extension not
#                     'html',              # handled as plain text (viewable in browser) with apache!
#                     'htm',
#                     'cgi',               # That line can be applied at first place when Apache return 
#  	             );                    # as plain text all files except script (.cgi)!

#[PATHS]
$driver_path = './drivers/';               # Driver`s path
$library_path = './libs/';                 # Librarie`s path
$db_path = './db/';                        # DB`s path
$mailsender_path = './mail/';              # Mail`s path
$xreader_path = './jhtml/';                # Path of xreader files(jhtml-s)
$perl_html_dir = './htmls/';               # Directory were peril’s html files are (/usr/local/apache/perlhtml/)
$apacheshtdocs = '/var/www/htdocs/';       # '/usr/local/apache/htdocs/'
$cgi_home_path = Get_CGI_Directory();      # Get webtools cgi-bin directory (exam: '/cgi-bin/webtools/')
					   # NOTE: This path is not absolute and is not an HTTP!!!
$http_home_path = '/dw/webtools/';         # Please change this to your http path!

$config_path   = PathMaker('./conf/','../conf/');
$library_path  = PathMaker($library_path,'.'.$library_path);
$db_path       = PathMaker($db_path,'.'.$db_path);
$driver_path   = PathMaker($driver_path,'.'.$driver_path);
$xreader_path  = PathMaker($xreader_path,'.'.$xreader_path);
$perl_html_dir = PathMaker($perl_html_dir,'.'.$perl_html_dir);

@use_addition_paths = ('./db/');  # Push paths in this array to force using of these
                                  # directories from Perl
foreach my $path (@use_addition_paths) { PathMaker($path,''); }  # Include additionls paths!

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
  if($pth ne '')
  {
    eval ("use lib \'$pth\';"); return($pth);
  }
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
 
1;