#####################################################################
# eXternal Reader
# eXtended Reader
# eXcalant Reader
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################

my $x_sep_begin1 = '\<\�N\�';
my $x_sep_begin2 = '\�(\d{1})\�(\w*?)\�\�\>';
my $x_sep_begin;
my $x_sep_end = '\<\�\�\�\>';
my $x_var = '\<\�VAR\�\>';
my $x_sqlvar = '\<S\�LVAR\:(\d{1,})\:S\�L\>';
my $x_SQL_begin = '\<S\�L\:(\d{1,})\:\"(.*?)\"\:(\d{1,})\:(\d{1,})\:(\d{1,})\:(\d{1,})\:S\�L\>';

$sys_xreader_file = '';
$sys_xreader_buf = '';

$sys_sql_dbh = undef;
%sys_xreader_queries = {};

#####################################################
# That function read from file HTML data (with some
# futures) and substitue SQL queries and vars with
# respective values!
# $scalar = xreader($N_of_part,$filename);
# 
# USAGE:
# 
# $SOURCE = xreader(1,'file_found_in_jhtml_path.jhtml',
#                  $count);
# where your custom jhtml file contain part structured
# as follow:
#--- Save under: file_found_in_jhtml_path.jhtml ---
#<�N�1�1���>
#Count of visitors: <�VAR�>
#<���>
#
# For more information about structure of jhtml files
# please see docs/xreader-legend.txt
#
# TODO: Make calling this function as HTML tag...
#####################################################
sub xreader
{

 my $number = shift(@_);
 my $filename = shift(@_);
 my @vals = @_;
 
 my $old_n = $/;
 $x_sep_begin = $x_sep_begin1.$number.$x_sep_begin2;
 my $data;
 
 if($sys_xreader_file eq $filename)
  {
   $data = $sys_xreader_buf;
  }
 else
  {
   undef $/;
   #print $xreader_path.$filename; 
   open(XFILE,$xreader_path.$filename) or return(0);
   binmode(XFILE);
   $data = <XFILE>;
   close (XFILE); 
   $/ = $old_n;
   $data =~ s/\r\n/\n/gs;
   $sys_xreader_file = $filename;
   $sys_xreader_buf = $data;
   %sys_xreader_queries = {};
  }
 return(_xreader($data,@vals));
}

#####################################################
# That function is a low level xreader function!
# Actualy, that sub will make all work for xreader()
# $scalar = _xreader($data);
#####################################################
sub _xreader
{
 my ($data) = shift(@_);
 my @vals = @_;
 my $xparts;
 my $xprt_w;
 my $xprt_n;
 my @VARS = ();
 
 $data =~ s/$x_sep_begin(.*?)$x_sep_end/do {
    $xprt_w = $1;
    $xprt_n = $2;
    $xpart = $3;
 };/se;
 if (($xprt_w eq '0') and ($xprt_n ne ''))
   {
    $sys_xreader_file = '';
    $sys_xreader_buf = '';
    %sys_xreader_queries = {};
    undef $/;
    open(XFILE,$xreader_path.$filename) or return(0);
    binmode(XFILE);
    $xpart = <XFILE>;
    close (XFILE); 
    $/ = $old_n;
   }
 my @newar = split(/$x_var/s,$xpart);
 $xpart = '';
 foreach $l (@newar)
  {
    my $loc = shift(@vals);
    $loc =~ s/\�\�\�//gs;
    if ($loc eq undef) { $loc = ''; }
    $xpart .= $l.$loc;
  }
 $xpart =~ s/^\n(.*)\n$/$1/s;
 $xpartb = $xpart;
 my $var_counter = 1;
 $xpart =~ s/$x_SQL_begin/do{
  my $numb = $1;
  my $q = $2;
  my $qd = $3;
  my $rq = $4;
  my $c = $5;
  my $visible = $6;
  my $res = '';
  if(exists($sys_xreader_queries{'Q'.$qd.'R'.$rq.'C'.$c}))
    {
     $res = $sys_xreader_queries{'Q'.$qd.'R'.$rq.'C'.$c};
    }
  elsif($sys_sql_dbh ne undef)
    {
     my $r = sql_query($q,$sys_sql_dbh);
     my $x = 1;
     my @arr;
     if($r ne undef)
      {
       while((@arr = sql_fetchrow($r)))
        {
       	 my $i = 1;
         foreach my $l (@arr)
           {
            my $nm = 'Q'.$numb.'R'.$x.'C'.$i;
            $sys_xreader_queries{$nm} = $l;
            $i++;
           }
         $x++;
         @arr = ();
        }
       my $dn = 'Q'.$numb.'R'.$rq.'C'.$c;
       $res = $sys_xreader_queries{$dn};
       }
     push(@VARS,$res); $var_counter++;
     if(!$visible) { $res = ''; }
    }
  else { $res = ''; }
  $xpartb =~ s!$x_SQL_begin!$res!si;
 };/sige;
 $xpart = $xpartb;
 $xpart =~ s/$x_sqlvar/do{
   my $cl = $VARS[$1-1];
   $xpartb =~ s!$x_sqlvar!$cl!si;
 };/sige;
 $xpart = $xpartb;
 return($xpart);
}

###################################
sub xreader_dbh ($)  # Set default DB Handler for SQL operations!
{
 $sys_sql_dbh = shift(@_);
}

##################################################
# Read all templates from file and query DB for
# respective Products IDs!
# USAGE:
# @Array_With_Prod_IDs = xshopreader('',$dbh,'my_products_html_template_page.html');
# or
# @Array = xshopreader($read_html_source,$dbh);

sub xshopreader
{
 my ($data,$dbh,$fname) = @_;
 my ($id,$q,$work,$r);
 my @arr;
 my @result = ();
 if($fname ne '')
   {
    local $/ = undef;
    open (SHOPT,$fname) or return(-2);
    $data = <SHOPT>;
    close (SHOPT);
   }
 # Please do not use "#" in follow block!
 # where $1 is ID number and $2 is SQL query returned ID
 # Example: 
 # <SHOP_ITEM:1:SELECT Product_ID FROM products WHERE Product_Hot='Y' AND Product_Category='0':>
 $data =~ s#\<SHOP\_ITEM\:(\d{1,10})\:(.*?)\:\>#do
   {
    $id = $1;
    $q  = $2;
    $r = sql_query($q,$dbh);
    if($r)
      {
       @arr = sql_fetchrow($r);
       push(@result,$arr[0]);
      }
    else { push(@result,-1);}
   };#sige;
 
 return(@result);
}

#######################################################
# USAGE:
# $SOURCE  = 'Message of the <B>day</B>: <�TEMPLATE:7�><br>';
# 
# $SOURCE = ReplaceTemplateWith(7,$SOURCE,'New release of Webtools is now available!');

sub ReplaceTemplateWith
 {
  my ($numb,$var,$msg) = @_;
  $var =~ s/\<\�TEMPLATE\:$numb\�\>/$msg/is;
  return($var);
 }

# Clear all fields that are not still replaced!
sub ClearAllTemplates
 {
  my ($var,$msg) = @_;
  $var =~ s/\<\�TEMPLATE\:\d{1,}\�\>/$msg/is;
  return($var);
 }

#######################################################
# USAGE:
# @DB_VALUES = ("Y","N","-");
# @TEMPLATE_NUMBERS = (1,2,3);
# @HTML_VALUES = ("checked","");
# $SOURCE  = '<input type="radio" name="Male" value="Y" <�TEMPLATE:1�>>Yes<br>';
# $SOURCE .= '<input type="radio" name="Male" value="N" <�TEMPLATE:2�>>No';
# $SOURCE .= '<input type="radio" name="Male" value="-" <�TEMPLATE:3�>>Unknown :-)';
# 
# $SOURCE = MenuSelect($SOURCE,"SELECT MenuState FROM MyTable WHERE Condition1 = $C1 AND ...",
#                      \@DB_VALUES,\@TEMPLATE_NUMBERS,\@HTML_VALUES,$dbh);
# TODO: Make calling this function as HTML tag...

sub MenuSelect
 {
  my ($var,$q,$SQL_ref,$VAR_ref,$MACH_ref,$dbh) = @_;
  my @SQL_arr = @$SQL_ref;
  my @VAR_arr = @$VAR_ref;
  my @MACH_arr = @$MACH_ref;
  my @row = ();
  my $sa_size = $#SQL_arr;
  my $ptr = 0;
  my $res = sql_query($q, $dbh);
  if($res) {@row = sql_fetchrow($res);}
  else { @row = (); }
  my $row_size = $#row;
  my $i;
  for ($i=0;$i<$sa_size;$i++)
    {
     $res = $row[$ptr];
     if($res == $SQL_arr[$i])
       {
        my $row_number = $VAR_arr[$i];
        $var = ReplaceTemplateWith($row_number,$var,$MACH_arr[0]);
        $r = $row[$ptr++];
        if($ptr <= $row_size) {$i = -1;}
        else {last;}
       }
    }
  if(($row[0] == '') && ($row_size == 1))
    {
     $var = ReplaceTemplateWith($VAR_arr[0],$var,$MACH_arr[0]);
    }
  my $va_size = sizeof($VAR_arr);
  for ($i=0;$i<$va_size;$i++)
    {
     $var = ReplaceTemplateWith($VAR_arr[$i],$var,$MACH_arr[1]);
    }
  return($var);
 }
#############################################################
# TODO: Make calling template functions as HTML tag...
# -----------------------Example----------------------
# Your name is:
# <!--�INLINE�><S�L:1:"select USER,ID from demo_users where id=1;":1:1:1:1:S�L></�INLINE�-->!
# <BR><!--�INLINE�><S�LVAR:1:S�L></�INLINE�-->`s ID is:
# <!--�INLINE�><S�L:2:"":1:1:2:1:S�L></�INLINE�-->!<BR>
# <!--�INLINE�><SHOP_ITEM:1:SELECT Product_ID FROM products WHERE Product_Hot='Y' AND Product_Avail='Y' AND Product_Category='0' LIMIT 0,1 :></�INLINE�-->
# Message of the <B>day</B>: <!--�INLINE�><�TEMPLATE:7:$val:�></�INLINE�--><br>
# <!--�INLINE�><MENUSELECT:$SOURCE:"SELECT MenuState FROM MyTable WHERE Condition1 = $C1 AND ...":\@DB_VALUES:\@TEMPLATE_NUMBERS:\@HTML_VALUES:$dbh:></�INLINE�-->
# <!--�INLINE�><XREADER:1:bestbuy.jhtml:$first_param,$second_param></�INLINE�-->
# ----------------------------------------------------
# All must be in perl code..so loops must work!


1;