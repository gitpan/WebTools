###############################################
# Dump library by Julian Lishev
# All rights reserved by www.proscriptum.com
# Used idea of Krasimir Krustev
###############################################
$sys_print_dump_buffer = '';

###############################################
# Dump example function
###############################################
sub printDump
{
 reset_dump_html();
 my @all_cgi = %formdatah;
 my $k;
 foreach $k (keys %global_hashes)
  {
   push (@all_cgi, $k);
   push (@all_cgi, $global_hashes{$k});
  }
 dump_hash('GET/POST CGI VARIABLES',@all_cgi);
 my @all_cgi = ();
 foreach $k (keys %sess_cookies)
  {
   if(!($k =~ m/^sys_debug_cookie_/s))  # Remove debug cookies from cookie list!
    {
     push (@all_cgi, $k);
     push (@all_cgi, $sess_cookies{$k});
    }
  }
 dump_hash('COOKIE VARIABLES',@all_cgi);
 dump_hash('SESSION VARIABLES',%SESREG);
 dump_hash('UPLOADED FILES',%uploaded_original_file_names);
 print make_dump_html(shift(@_));
}

sub reset_dump_html
{
 $sys_print_dump_buffer = '';
}

###############################################
# Make dump html code
# PROTO: 
# $html = make_dump_html($type_of_html);
# $type_of_html can be: html,popup and layer
###############################################
sub make_dump_html
{
 my $th = shift || 'popup';
 my $full = $sys_print_dump_buffer;
 if($th =~ m/^popup$/si)
  {
   my $hf = qq~<HTML><BODY>
  <A href="JavaScript: window.close();"><FONT COLOR="DARKBLUE" FACE="Verdana,Arial"><B>Close debug window</B></FONT></A><BR>
  ~;
   $full = $hf.$full.'<BR>'.$hf.'</BODY></HTML>';
   my $data = "var data = '".dump_encoding_data($full)."';";
   my $js = qq~
   <SCRIPT language="JavaScript">
   <!--
   $data
   var debug_window;
   var w = 780;
   var h = 450;
   var winl = (screen.width-w)/2;
   var wint = (screen.height-h)/2;
   data = unescape(data);
   function pop_up_debug_window(name)
    {
     window.focus();
     debug_window = window.open('about:blank',name,'scrollbars=yes,width='+w+',height='+h);
     debug_window.close();
     debug_window = window.open('about:blank',name,'scrollbars=yes,width='+w+',height='+h);
     debug_window.document.write(data);
     debug_window.document.title = name;
     debug_window.moveTo(winl,wint);
     debug_window.focus();
    }
   pop_up_debug_window('Debug');
   //-->
   </SCRIPT>
   ~;
   return $js;
  }
 if($th =~ m/^html$/si)
  {
   return $full;
  }
 if($th =~ m/^layer$/si)
  {
   $full .= "<BR>";
   my $js = qq~
   <SCRIPT language="JavaScript">
   <!--
   var flager=0;
   var outer=0;
   var wind;
   var pos_x_1=0;
   var pos_x_2=0;
   var pos_y_1=0;
   var pos_y_2=0;
   var offset_x=0;
   var offset_y=0;
   var center_w=5;
   var vis=1;
   var begin_flag=0;
   
   function read_cookie(name)
   {
    var stop,index;
    
    index = document.cookie.indexOf(name + "=");
    if (index == -1) return (0);
    index = document.cookie.indexOf("=", index) + 1;
    stop = document.cookie.indexOf(";", index);
    if (stop == -1) stop = document.cookie.length;
    return(unescape(document.cookie.substring(index, stop)));
   }
   function write_cookie(name,value)
   {
    var cookie = name + "=" + value + ";";
    document.cookie = cookie;
   }
   function alert_keycode(){
    if(event.keyCode == 11) // CTRL+L
     {
      if(vis == 0)
       {
       	Open_Layer();
       	vis = 1;
       }
      else
       {
       	Close_Layer();
       	vis = 0;
       }
     }
   }
   function processkey(e){
    if(e.which == 11) // CTRL+L
     {
      if(vis == 0)
       {
       	Open_Layer();
       	vis = 1;
       }
      else
       {
       	Close_Layer();
       	vis = 0;
       }
     }
   }
   if(document.all){
    document.onkeypress=alert_keycode
   }
   else {
    document.captureEvents(Event.KEYPRESS)
    document.onkeypress=processkey
   }
   
   function flag(a)
   {
    flager = a;
   }
   function outit(a)
   {
    outer = a;
   }
   function get_x(a)
   {
    if(begin_flag > 0) {begin_flag --;a=1;}
    if(a == 1)
     {
      pos_x_1 = 0;
      return(read_cookie('sys_debug_cookie_x'));
     }
    else
     {
      return(window.event.x);
     }
   }
   function get_y(a)
   {
    if(begin_flag > 0) {begin_flag --;a=1;}
    if(a == 1)
     {
      pos_y_1 = 0
      pos_y_2 = 19;
      return(read_cookie('sys_debug_cookie_y'));
     }
    else
     {
      return(window.event.y);
     }
   }
   function moveit(debuglaycapt,debuglaybody)
   {
    var tx,ty;
    var a,i;
    if(document.all){
    if(flager == 1)
     {
      g_x = get_x(0);
      g_y = get_y(0);
      
      tx = g_x - center_w;
      ty = g_y - center_w;
      pos_x_1 = pos_x_1 + tx;
      pos_y_1 = pos_y_1 + ty;
      pos_y_2 = pos_y_2 + ty;
      
      var my_x = pos_x_1+center_w;
      var my_y = pos_y_1+center_w;

      if(parseInt(my_x) > 1024) {my_x=5; my_y=5;}
      if(parseInt(my_x) < 0) {my_x=5; my_y=5;}
      if(parseInt(my_y) > 1280) {my_x=5; my_y=5;}
      if(parseInt(my_y) < 0) {my_x=5; my_y=5;}

      write_cookie('sys_debug_cookie_x',my_x);
      write_cookie('sys_debug_cookie_y',my_y);
      
      if(pos_x_1 < 0) pos_x_1 = 0;
      if(pos_y_1 < 0) {pos_y_1 = 0; pos_y_2 = 24;}
      
      debuglaycapt.style.top = pos_y_1;
      debuglaycapt.style.left= pos_x_1;
      debuglaybody.style.top = pos_y_2;
      debuglaybody.style.left= pos_x_1;
      
      flager=0;
      outer=0;
     }
     flager=0;
    }
   }
   function check(debuglaycapt,debuglaybody)
   {
    if(document.all){
    if (flager == 0) outer = 0;
    else outer = 1;
    moveit(debuglaycapt,debuglaybody);
    }
   }
   function Min_Max_Layer()
    {
     if(document.all)
      {
       if(document.all.debuglaybody.style.visibility == 'visible')
        {
         document.all.debuglaybody.style.visibility = 'hidden';
         write_cookie('sys_debug_cookie_min_max','H');
        }
       else
        {
         document.all.debuglaybody.style.visibility = 'visible';
         write_cookie('sys_debug_cookie_min_max','V');
        }
      }
     else
      {
       if(document.debuglaybody.visibility != 'hide')
        {
         document.debuglaybody.visibility = 'hide';
         write_cookie('sys_debug_cookie_min_max','H');
        }
       else
        {
         document.debuglaybody.visibility = 'visible';
         write_cookie('sys_debug_cookie_min_max','V');
        }
      }
    }
   function Close_Layer()
    {
     vis = 0;
     write_cookie('sys_debug_cookie_visible','H');
     if(document.all)
      {
       document.all.debuglaycapt.style.visibility = 'hidden';
       document.all.debuglaybody.style.visibility = 'hidden';
       document.all.movein.style.visibility = 'hidden';
      }
     else
      {
       document.debuglaycapt.visibility = 'hide';
       document.debuglaybody.visibility = 'hide';
      }
    }
   function Open_Layer()
    {
     vis = 1;
     write_cookie('sys_debug_cookie_visible','V');
     if(document.all)
      {
       document.all.debuglaycapt.style.visibility = 'visible';
       document.all.debuglaybody.style.visibility = 'visible';
       document.all.movein.style.visibility = 'visible';
      }
     else
      {
       document.debuglaycapt.visibility = 'visible';
       document.debuglaybody.visibility = 'visible';
      }
    }
   //-->
   </SCRIPT>
   <div id="debuglaycapt" style="position:absolute; z-index:1; visibility: visible; top: 5px; left: 5px; width: 780; overflow: none; height: 20"> 
   <table width="780" border="1" cellspacing="0" cellpadding="0" bordercolor="#0000FF">
    <tr>
      <script language"JavaScript">
      if(document.all)
       {
         document.writeln('<td width="10" bgcolor="#0060A0">');
         document.writeln('<DIV id="movein" style="position:relative; z-index:1; visibility: visible; top: 0px; left: 0px; width: 20px; overflow: none;" align="left" onmousedown="flag(1),outit(1);" onmouseout="check(debuglaycapt,debuglaybody);" onmouseup="javascript:flag(0);"><IMG ALT="To move window please drag this image!" SRC="about:blank" width="20" HEIGHT="20"></DIV>');
         document.writeln('</td>');
       }
      </script>
      <td width="100%" bgcolor="#0099FF"> 
        <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#FFFF00"><b>Debug 
          Window <font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#004FB0">- Press CTRL+K to hide/show window</font></b></font></div>
      </td>
      <td width="1" bgcolor="#0099FF"> 
        <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#FFFF00"><b><font size="3"><font size="2">&nbsp;<a href="javascript: Min_Max_Layer();">M</a>&nbsp;</font></font></b></font></div>
      </td>
      <td width="1" bgcolor="#0099FF"> 
        <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#FFFF00"><b><font size="3"><font size="2">&nbsp;<a href="javascript: Close_Layer();">X</a>&nbsp;</font></font></b></font></div>
      </td>
    </tr>
   </table>
   </div>
   <div id="debuglaybody" style="position:absolute; z-index:1; visibility: hidden; top: 24px; left: 5px; width: 780; overflow: auto; height: 430"> 
   <table width="780" border="1" cellspacing="0" cellpadding="0" bordercolor="#0000FF">
    <tr> 
      <td bgcolor="#F5F5FA">
       $full
      </td>
    </tr>
   </table>
   </div>
   <script language="JavaScript">
   if(document.all){
     pos_x_1 = parseInt(debuglaycapt.style.left);
     pos_x_2 = parseInt(debuglaybody.style.left);
     pos_y_1 = parseInt(debuglaycapt.style.top);
     pos_y_2 = parseInt(debuglaybody.style.top);
     offset_x = pos_x_2 - pos_x_1;
     offset_y = pos_y_2 - pos_y_1;
     center_w = parseInt(movein.style.width) / 2;
     begin_flag = 2;
     flag(1);outit(1);
     check(debuglaycapt,debuglaybody);
     flag(0);
   }
   var rc_state_v = read_cookie('sys_debug_cookie_visible');
   var rc_state_m = read_cookie('sys_debug_cookie_min_max');
   rc_state_v
   if(rc_state_v == 'V' || rc_state_v == 0)
    {
     Open_Layer(); vis=1;
     if(rc_state_m == 'H')
      {
       Min_Max_Layer();
      }
    }
   else {Close_Layer(); vis=0;}
   </script>
   ~;
   return $js;
  }
}

###############################################
# Dump one hash
# PROTO: 
# $html = dumphasg('Title',%hash_with_vars);
###############################################
sub dump_hash
{
  my $title = shift;
  my %hash  = @_;
  my $VA;
  my $full = '';
  
  my $ii;
  $full = qq~
  <BR><CENTER>
  <TABLE WIDTH="740" BORDER="1" BGCOLOR="#E0E0E0">
  <TR>
    <TD COLSPAN="2" BGCOLOR="#C0C0C0"><B><FONT COLOR="BLUE" FACE="Verdana,Arial">$title</FONT></B></TD>
  </TR>
  ~;
  if(scalar(%hash) != 0)
   { 
    foreach $ii (keys %hash){
      $VA = $hash{$ii} || '&nbsp;';
      if(ref($VA))
       {
        my $copy = $VA;
        $VA = '';
       	if($copy =~ m/^ARRAY/si)
       	 {
       	  my @marr = @$copy;
          if(scalar(@marr) > 0)
       	   {
       	    my $ks;
       	    my $ci = 0;
       	    foreach $ks (@marr)
       	     {
       	      $VA .= '<font color="#E02020"><B>['.$ci.']</B></font> = '.$ks."\n";
       	      $ci++;
       	     }
           }
          else {$VA .= '&nbsp;'}
         }
       	else
       	 {
       	  my %mhash = %$copy;
       	  if($copy =~ m/^HASH/si)
       	    {
       	     if(scalar(%mhash) > 0)
       	      {
       	       my $ks;
       	       foreach $ks (keys %mhash)
       	        {
       	         $VA .= '<font color="#E02020"><B>'.$ks.'</B></font> => '.$mhash{$ks}."\n";
       	        }
       	      }
       	     else {$VA .= '&nbsp;'}
       	    }
       	  else
       	   {
       	    $VA = '&nbsp;';
       	   }
         }
       }
      if(length($VA) > 2048)
      {
       $VA  = substr($VA,0,2048);
       $VA = break_down_scalar($VA,80);
       $VA .= '<FONT COLOR="RED" FACE="Verdana,Arial" size=2><B><BR>... more data follows</B></FONT>';
      }
     else
      {
       $VA = break_down_scalar($VA,80);
      }
      $full .= qq~
      <TR VLAIGN="top">
        <TD WIDTH="120" COLSPAN="0"><table border="0"><TR><TD COLSPAN="0"><FONT COLOR="BLUE" FACE="Verdana,Arial" size="2"><B>$ii</B></FONT></TD></TR></TABLE></TD>
        <TD width="100%"><FONT COLOR="BLACK" FACE="Verdana,Arial"><TT>$VA</TT></FONT></TD>
      </TR>
      ~;
     }
   }
   else
    {
     $full .= qq~
      <TR VLAIGN="top">
        <TD width="100%"><FONT COLOR="BLUE" FACE="Verdana,Arial" size=4><B><TT><center>Empty</center></TT></B></FONT></TD>
      </TR>
      ~;
    }
  $full .= '</TABLE></CENTER>';
  $sys_print_dump_buffer .= $full;
 return(1);
}

sub break_down_scalar
{
 my $str = shift;
 my $brkchars = shift || 100;
 my $cnt = 0;
 my $new = '';
 $str =~ s/\<BR\>/\n/sig;
 $str =~ s/(.)/do{
  my $c = $1;
  if($cnt > $brkchars) {$new .= "\n"; $cnt = 0;}
  if(($c ne "\n") and ($c ne " "))
   {
    $cnt++; $new .= $c;
   }
  else { $cnt = 0; $new .= ($c eq ' ' ? ' ' : "\n"); }
 };/sge;

 $new =~ s/\n/<BR>/sg;
 return($new);
}

sub dump_encoding_data {
  my $str = shift;
  return undef unless defined($str);
  $str =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/seg;
  return $str;
}

1;