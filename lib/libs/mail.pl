#################################################
# This lib was originally written by
# Krasimir Krystev (c) Mole Software 
#
# Library modified by: Svetoslav Marinov and
# rewritten by Julian Lishev
#################################################
# Subs: send_mail mail mx_lookup
#       set_attached_files
#       remove_mail_attachment
#       clear_all_mail_attachments
# Prereqired modules:
#       MIME::QuotedPrint and MIME::Base64
#################################################
# send_mail(FROM,TO,SUBJECT,BODY,AS_HTML);
#################################################
require './conf/config.pl';

%mole_attached_files = ();  # Please use "set_mail_attachment" and "remove_mail_attachment"
                            # instead of direct manipulating of hash.
$webtools::loaded_functions = $webtools::loaded_functions | 64;
sub send_mail 
  {
    use MIME::QuotedPrint;  
    local($from, $to, $subject, $messagebody, $is_html) = @_;
    local($fromuser, $fromsmtp, $touser, $tosmtp);
    my $crlf = "\r\n";
    
    if(($is_html =~ m/^YES$/si) or ($is_html =~ m/^ON$/si) or ($is_html eq '1'))
      {
       $is_html = 1;
      }
    else {$is_html = 0;}
    
    if(!($to =~ m/^([A-Za-z0-9\_\-\.]+)\@([A-Za-z0-9\_\-\.]+)\.([A-Za-z0-9\_\-\.]+)$/si))
      {
       return -1; # Bad e-mail address (or not supported from my regex)
      }
    if ($messagebody =~ /\<html\>/is) 
      {
       $is_html = 1; # Force HTML mode
      }
    if ($is_html)
      {
       if ($debug_mail ne 'on') 
         {
          $messagebody =encode_qp($messagebody);
         }
      }
    $fromuser = $from;
    $touser = $to;

    $fromsmtp = (split(/\@/,$from))[1];
    $tosmtp = (split(/\@/,$to))[1];
    
    if ($debug_mail ne 'on')
      {
       return(real_send_mail($fromuser, $touser, $subject, $messagebody, $is_html));
      }
    else
      { 
       if (!$is_html)
        {
         writeMailToFile($mailsender_path,'.sent',"FROM:".$fromuser."\n"."TO:".$touser."\n"."SUBJECT:".$subject."\n"."BODY:\n\n".$messagebody."\n");
        }
       else
        {
         writeMailToFile($mailsender_path,'.html.sent',"<HTML>FROM:".$fromuser."<BR>TO:".$touser."<BR>SUBJECT:".$subject."<BR>BODY:<BR><BR>".$messagebody."<BR><BR></HTML>");
        }
       %mole_attached_files = ();   # Attachments are now cleared
       return(1);    # In debug mode mail always successed!
     }
}

sub set_mail_attachment 
{
  my ($original_file_name,$server_file_name) = @_;
  $original_file_name =~ s/.*(\/|\\)(.*)$/$2/s;
  if($original_file_name eq '') {$original_file_name = 'webtools_upload_'.(rand()*1000);}
  $mole_attached_files{$original_file_name} = $server_file_name;
}

sub remove_mail_attachment 
{
  my ($original_file_name) = @_;
  delete($mole_attached_files{$original_file_name});
}

sub clear_all_mail_attachments
{
  %mole_attached_files = ();
}

sub real_send_mail 
{
  local($fromuser, $touser, $subject, $messagebody, $is_html) = @_;
    
  local($old_path) = $ENV{"PATH"};
  $ENV{"PATH"} = "";
  local *MAIL;
  open (MAIL, "|$mail_program") || return(-1);    # Can't open SendMail
  $ENV{"PATH"} = $old_path;
    
  my %MIMETYPES = ('zip','application/zip','exe','application/octet-stream','doc','application/msword',
                  'report','application/zip','mpga','audio/mpeg','mp3','audio/mpeg','gz','application/x-gzip',
                  'gzip','application/x-gzip','xls','application/vnd.ms-excel','pdf','application/pdf',
                  'swf','application/x-shockwave-flash','tar','application/x-tar','midi','audio/midi',
                  'mid','audio/midi','bmp','image/bmp','gif','image/gif','jpeg','image/jpeg','jpg','image/jpeg',
                  'jpe','image/jpeg','pgn','image/png','html','text/html','htm','text/html','mpeg','video/mpeg',
                  'mpg','video/mpeg','mpe','video/mpeg','avi','video/x-msvideo','movie','video/x-sgi-movie');
 
 use MIME::Base64;
 
 my $crlf = "\r\n";
 my $boundary = "MZ8dd988d1d73016OQ104bWebTools050010191".(int(rand()*1000000000)+192837460)."PE";
 my $next_boundary = $crlf.'--'.$boundary.$crlf;
 my $last_boundary = $crlf.'--'.$boundary.'--'.$crlf;
 my $a_boundary = "ZM".(int(rand()*1000000000)+192837460)."0018104bd730WebTools0598dd16OQ8d10191"."EP";
 my $a_next_boundary = $crlf.'--'.$a_boundary.$crlf;
 my $a_last_boundary = $crlf.'--'.$a_boundary.'--'.$crlf;
 my $charset = 'Content-type: text/html; charset=us-ascii';
 my $html  = 'Message-ID: <'.(int(rand()*1000000000)+83649814).'.cae99500.2e0aa8c0@localhost>'.$crlf;
 
 $html .= "From: ".$fromuser.$crlf;
 $html .= "To: ".$touser.$crlf;
 $html .= 'X-Priority: 2'.$crlf;
 $html .= 'X-MSMail-Priority: Normal'.$crlf;

 $html .= "Subject: ".$subject.$crlf;
 $html .= 'MIME-Version: 1.0'.$crlf;
 if(($is_html) or (%mole_attached_files))
   {
    #---------------------------------------------------------------------------
    $html .= 'Content-type: multipart/mixed; boundary="'.$boundary.'"';
    $html .= $crlf;
    $hmtl .= 'This message is in MIME 1.0 format.';
    $html .= $crlf;
    $html .= $next_boundary;
    $html .= 'Content-type: multipart/alternative; boundary="'.$a_boundary.'"';
    $html .= $crlf;
    $hmtl .= 'This alternative message is in MIME 1.0 format.';
    $html .= $crlf;
  if($messagebody ne '')
     {
       #------------------------------------------------------------------------
       $html .= $a_next_boundary;
       $html .= $charset.'; name="document.html"';
       $html .= $crlf;
       $html .= 'Content-Transfer-Encoding: quoted-printable';
       $html .= $crlf;
       $html .= $crlf;
       $html .= encode_qp($messagebody);
       $html .= $a_last_boundary;
       if(!(print (MAIL $html))){return(-1);} # -1 Can`t send to SendMail
       $html = '';
     }
 if (%mole_attached_files)
  {
   my ($file,$ext,$type);
   my $cnt = 0;
   my $data;
   foreach $file (keys %mole_attached_files)
   {
    local *ATTCH;
    open (ATTCH,$mole_attached_files{$file}) or next;
    binmode (ATTCH);
    if(($file =~ m/^.*\.(.*)$/s))
     {
      $ext = $1;
     }
    else 
     {
      $ext = '';
     }
    $type = $MIMETYPES{$ext};
 if (($type eq '') or ($ext eq '')) { $type = 'application/octet-stream'; }
    #-----------------------------------------------------------------------------
    $html .= $next_boundary;
    $html .= 'Content-type: '.$type.'; name="'.$file.'"';
    $html .= $crlf;
    $html .= 'Content-Transfer-Encoding: base64';
    $html .= $crlf;
    $html .= 'Content-Disposition: attachment; filename="'.$file.'"';
    $html .= $crlf;
    $html .= $crlf;
    while($data = <ATTCH>)
    {
    $html .= encode_base64($data);
    if(!(print (MAIL $html))){return(-1);} # -1 Can`t send to SendMail
    $html = '';
    }
    close (ATTCH);
   }
  }
  #--------------------------------------------------------------------------------------------------------
  $html .= $last_boundary;
 }
 else
 {
 if($messagebody ne '')
  {
   $html .= $crlf.$messagebody;
  }
 }
 if(!(print (MAIL $html))){return(-1);} # -1 Can`t send to SendMail
    
 close (MAIL);
 %mole_attached_files = ();   # Attachments are now cleared.
 return(1);
}

sub web_error {
  my ($msg) = @_;
  
  ClearBuffer(); ClearHeader(); flush_print();
  
  print "<br><font color='red'><h3>";
  print "<p>$msg</p>\n";
  print "</h3></font>";
  
  die ':QUIT:';
}

sub find_mail_program{
  if ($debug_mail eq 'on'){ return 'MAIL_TEST'; }
  local @mailer = ($sendmail,'/usr/lib/sendmail','/usr/bin/sendmail','/usr/sbin/sendmail');
  local $flags  = "-t";
  local $st;
  foreach $st (@mailer){ if ( -e $st){return "$st $flags";}  }
  return("$sendmail $flags");
}


sub writeMailToFile
  {
    my ($temp_dir,$ext,$buffer) = @_;
    my $file_for_attach = '';
    
    foreach my $file (keys %mole_attached_files)
      {
      	$file =~ s/.*(\/|\\)(.*)$/$2/s;
      	$file_for_attach .= $file."\n";
      }
    my (undef,$file) = each (%mole_attached_files);

    $file =~ s/.*\/(.*)$/$1/; 
    if (!($temp_dir =~ /.*\/$/)) { $temp_dir .= '/';}
    # generation of a file name, in test mode usually :)
    my $rndf = rand()*1000;
    if($file ne '') {$rndf = '';}
    $webtools_gen_file_name = $temp_dir.'webtools_'.$rndf.$file.$ext;
    local *FILE;
    open    (FILE,">$webtools_gen_file_name") or return('');
    binmode (FILE);
    print   (FILE "$buffer");
    print   (FILE "\nAttachments: \n$file_for_attach");
    close   (FILE);

    return 1;            
  }

sub readAttach 
  {
    my $filename = shift(@_); 
    return '' if ($filename eq '');
    local $/ = undef;
    my $data;
    local *FILE;
    open (FILE,$filename) or return('');
    binmode (FILE);
    $data = <FILE>;    
    close (FILE);
    
    return $data;
  }

sub mail
{
 eval {use Socket;};
 eval {use FileHandle;};
 my $iterative = 0;
 
 my %inp = @_;
 
 while($iterative < 5)
  {
   my ($code,$data) = talk_to_smpt(%inp);
   if(($code == 251) or ($code == 551))
    {
     # Get e-mail and useit in mail call...
     if($data =~ m/\<([A-Za-z0-9\_\-\.]+)\@([A-Za-z0-9\_\-\.]+)\.([A-Za-z0-9\_\-\.]+)?(\>|\;|\:|\ )/is)
       {
        $inp{'to'} = $1.'@'.$2.'.'.$3;
       }
     else
      {
       return(550);
      }
     $iterative++;
    }
   else
    {
     return($code);
    }
  }
 return(0);
}

sub talk_to_smpt
{
 my %inp = @_;
 my $crlf = "\r\n";
 my ($timeout,$from,$to,$subject,$body,$replyto,$raw,$ns_lookup,$qfrom,$text);
 my ($peer,$user,$ip,$data,$fdom,$html,$charset,$priority) = ();
 my @res = ();
 
 if(exists($inp{'timeout'})) {$timeout = $inp{'timeout'};}
 else {$timeout = 40;}

 if(exists($inp{'from'})) {$from = 'From: '.$inp{'from'}.$crlf; $qfrom = $inp{'from'};}
 else {$from = ''; $qfrom = '';}
 
 if(exists($inp{'to'})) {$to = 'To: '.$inp{'to'}.$crlf;}
 else {return(-1);}                                   # No receiver!
 
 if(exists($inp{'subject'})) {$subject = 'Subject: '.$inp{'subject'}.$crlf;}
 else {$subject = '';}
 
 if(exists($inp{'replyto'})) {$replyto = 'Reply-to: '.$inp{'replyto'}.$crlf;}
 else {$replyto = '';}
 
 if(exists($inp{'body'})) {$body = $inp{'body'};}
 else {$body = '';}
 
 if(exists($inp{'text'})) {$text = $inp{'text'};}
 else {$text = '';}
 
 if(exists($inp{'date'})) {$date = 'Date: '.$inp{'date'}.$crlf;}
 else {$date = '';}
 
 if(exists($inp{'raw'})) {$raw = $inp{'raw'};}
 else {$raw = '';}
 
 if(exists($inp{'nslookup'})) {$ns_lookup = $inp{'nslookup'};}
 else {$ns_lookup = '';}
 
 if(exists($inp{'charset'})) {$charset = $inp{'charset'};}
 else {$charset = 'Content-type: text/html; charset=us-ascii';}
 
 if(exists($inp{'priority'})) 
   {
    $priority = $inp{'priority'};
    if(($priority =~ m/HIGH/si) or ($priority eq 0)) {$priority = 0;}
    if(($priority =~ m/NORMAL/si) or ($priority eq 1)) {$priority = 1;}
    if(($priority =~ m/LOW/si) or ($priority eq 2)) {$priority = 2;}
   }
 else {$priority = 1;}
 
 if(exists($inp{'html'})) 
   {
    $html = $inp{'html'};
    if(($html == 1) or ($html =~ m/^YES$/si) or ($html =~ m/^ON$/si)) {$html = 1;}
    else {$html = 0;}
   }
 else {$html = 0;}
 
 $to =~ m/^To\: ([A-Za-z0-9\_\-\.]+)\@([A-Za-z0-9\_\-\.]+)\.([A-Za-z0-9\_\-\.]+)\r\n$/is;
 $peer = $2.'.'.$3;
 $user = $1;
 
 $qfrom =~ m/^([A-Za-z0-9\_\-\.]+)\@([A-Za-z0-9\_\-\.]+)\.([A-Za-z0-9\_\-\.]+)$/is;
 $fdom  = $2.'.'.$3;
 
 my $proto = getprotobyname('tcp');
 local *Sock;
 socket(Sock, AF_INET, SOCK_STREAM, $proto);
 my $port = 25;
 
 my $query = $peer;
 $query =~ s/^\ *//s;
 $query =~ s/\ *$//s;
 
 if($query =~ m/^\d{1,3}\./s)
  {
   $query = gethostbyaddr(inet_aton($query), AF_INET);
   $query =~ s/^.*\.(.*)\.(.*)^/$1\.$2/s;
   my @host = split(/\./,$query);
   if($#host > 1) {$query = $host[-2].'.'.$host[-1];}
  }
  
 my @ips = mx_lookup($query,$ns_lookup);
 if($#ips == -1) {@ips = ($peer);}
 
 my $flag_succ = 0;
 
 foreach $ip (@ips)
  {
   $ip =~ m/^\d{1,5}\t(.*?)$/s;
   $ip = $1;
   my $sin = sockaddr_in($port,inet_aton($ip));
   $isconnected = connect(Sock,$sin);
   if ($isconnected)
     {					       # ?Mail server? not responding!?
      @res = ReadFromSocket(Sock,$timeout);
      if($res[0] == 220)
        {
         $flag_succ = 1;
         last;
        }
     }
   else
    {
     @res = (0,'');                            # Can't connect.
    }
  }
  if($flag_succ)
   {
    if(send(Sock,"HELO $fdom".$crlf,0) eq undef){return(-1);} # -1 Can`t send to socket
    @res = ReadFromSocket(Sock,$timeout);
    if($res[0] != 250) {return(($res[0],$res[1]));}

    if(send(Sock,"MAIL FROM:<$qfrom>".$crlf,0) eq undef){return(-1);} # -1 Can`t send to socket
    @res = ReadFromSocket(Sock,$timeout);
    if($res[0] != 250) {return(($res[0],$res[1]));}
    
    if(send(Sock,"RCPT TO:<$user\@$peer>".$crlf,0) eq undef){return(-1);} # -1 Can`t send to socket
    @res = ReadFromSocket(Sock,$timeout);
    if($res[0] != 250) {return(($res[0],$res[1]));}     # 251,551 (redirect) ?
    
    if(send(Sock,"DATA".$crlf,0) eq undef){return(-1);} # -1 Can`t send to socket
    @res = ReadFromSocket(Sock,$timeout);
    if($res[0] != 354) {return(($res[0],$res[1]));}
    if($raw eq '')
     {
      mail_data('from'=>$from,'to'=>$to,'subject'=>$subject,'body'=>$body,'replyto'=>$replyto,
                'date'=>$date,'html'=>$html,'text'=>$text,'charset'=>$charset,'priority'=>$priority,
                'sock'=>Sock);
     }
    else
     {
      $data = $raw;      # $raw should contain all data that needed for DATA command to smpt!!!
                         # don't forget to put "CRLF.CRLF" sequence!
     }
    if(send(Sock,$data,0) eq undef){return(-1);} # -1 Can`t send to socket
    @res = ReadFromSocket(Sock,$timeout);
    if($res[0] != 250) {return(($res[0],$res[1]));}
    if(send(Sock,"QUIT".$crlf.'.'.$crlf,0) eq undef){return(-1);} # -1 Can`t send to socket
    @res = ReadFromSocket(Sock,$timeout);
    if($res[0] != 221) {return(($res[0],$res[1]));}
    close (Sock);
    return((220,$res[1]));					   # OK, mail sent!
   }
  return(($res[0],$res[1]));
}

# @ips = mx_lookup($domain_or_ip, [$path_to_nslookup]);
sub mx_lookup
{
 eval {use Socket;};
 my $result;
 my $domain = shift;
 my @digout;
 my $line;
 my @mxrecs = ();
 my $nslookup = $_[0] ne '' ? shift(@_) : 'nslookup';
 my $qrt = $domain;
 $qrt =~ s/\./\\\./sig;
 $nslookup .= " -q=MX $domain";
 @digout =  `$nslookup`;
 foreach $line (@digout) 
  {
   if($line =~ m/^$qrt\x9(MX)?\ ?preference\ =\ (\d{1,5})\, mail\ exchanger\ =\ (.*?)$/si)
    {
     my $h = $3;
     my $prority = $2;
     if ($h =~ m/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/s)
       {
        $h = $1;
        push(@mxrecs,$prority."\t".$h);
       }
     else
       {
        $h =~ s/\.$//s;
        $h =~ s/^[\ \t\r\n]*//s;
        $h =~ s/[\ \t\r\n]*$//s;
        (undef, undef, undef, undef, @addrs) = gethostbyname($h);
        $h  = inet_ntoa($addrs[0]);
        push(@mxrecs,$prority."\t".$h);
       }
    }
 }
 return sort(@mxrecs);
}

# $code = ReadFromSocket(SOCK, $timeout);
sub ReadFromSocket
 {
   local (*Hand) = $_[0];
   my ($line,$l_line) = ();
   my $timeout = $_[1];
   my $rbits = "";
   my $done = 0;
   vec($rbits, fileno(Hand), 1) = 1;
   my $finish_time = time() + $timeout;
   while (!$done && $timeout > 0)          # Keep trying if we have time
      {
       my $nfound = select($rbits, undef, undef, $timeout); # Wait for packet
       $timeout = $finish_time - time();   # Get remaining time
       if (!defined($nfound))              # Hmm, a strange error
        {
         return(0,'');
        }
       else
        {
          if ($nfound == 0) { return (0); }
          while ($line = <Hand>)
            {
             $l_line .= $line."<BR>";
             if ($line =~ m/\d{3} /) {last;};
            }
         $done = 0;
        }
       if (defined($line)) {last;}
      }    
    $l_line  =~ m/^(\d{3})/;
    return (($1,$l_line));
 }

sub mail_data
{
 my %inp = @_;
 my ($from,$to,$subject,$body,$replyto,$date,$is_html,$text,$charset,$priority);
 local *Hand = $inp{'sock'};
 $from = $inp{'from'};
 $to = $inp{'to'};
 $subject = $inp{'subject'};
 $body = $inp{'body'};
 $text = $inp{'text'};
 $date = $inp{'date'};
 $replyto = $inp{'replyto'};
 $is_html = $inp{'html'};
 $charset = $inp{'charset'};
 $priority = $inp{'priority'};
 my $priority_level = 'Normal';
 if($priority == 0) {$priority_level = 'High';}
 if($priority == 1) {$priority = 3;}
 if($priority == 2) {$priority_level = 'Low'; $priority = 5;}
 my %MIMETYPES = ('zip','application/zip','exe','application/octet-stream','doc','application/msword',
                  'report','application/zip','mpga','audio/mpeg','mp3','audio/mpeg','gz','application/x-gzip',
                  'gzip','application/x-gzip','xls','application/vnd.ms-excel','pdf','application/pdf',
                  'swf','application/x-shockwave-flash','tar','application/x-tar','midi','audio/midi',
                  'mid','audio/midi','bmp','image/bmp','gif','image/gif','jpeg','image/jpeg','jpg','image/jpeg',
                  'jpe','image/jpeg','pgn','image/png','html','text/html','htm','text/html','mpeg','video/mpeg',
                  'mpg','video/mpeg','mpe','video/mpeg','avi','video/x-msvideo','movie','video/x-sgi-movie');
 
 use MIME::QuotedPrint;  
 use MIME::Base64;
 
 my $crlf = "\r\n";
 my $boundary = "MZ8dd988d1d73016OQ104bWebTools050010191".(int(rand()*1000000000)+192837460)."PE";
 my $next_boundary = $crlf.'--'.$boundary.$crlf;
 my $last_boundary = $crlf.'--'.$boundary.'--'.$crlf;
 my $a_boundary = "ZM".(int(rand()*1000000000)+192837460)."0018104bd730WebTools0598dd16OQ8d10191"."EP";
 my $a_next_boundary = $crlf.'--'.$a_boundary.$crlf;
 my $a_last_boundary = $crlf.'--'.$a_boundary.'--'.$crlf;

 my $html  = 'Message-ID: <'.(int(rand()*1000000000)+83649814).'.cae99500.2e0aa8c0@localhost>'.$crlf;
 $html .= $replyto;
 $html .= $from;
 $html .= $to;
 $html .= 'X-Priority: '.$priority.$crlf;
 $html .= 'X-MSMail-Priority: '.$priority_level.$crlf;

 $html .= $subject;
 $html .= $date;
 $html .= 'User-Agent: WebTools mail client'.$crlf;
 $html .= 'MIME-Version: 1.0'.$crlf;
 if(($is_html) or (%mole_attached_files))
   {
    #---------------------------------------------------------------------------
    $html .= 'Content-type: multipart/mixed; boundary="'.$boundary.'"';
    $html .= $crlf;
    $hmtl .= 'This message is in MIME 1.0 format.';
    $html .= $crlf;
    $html .= $next_boundary;
    $html .= 'Content-type: multipart/alternative; boundary="'.$a_boundary.'"';
    $html .= $crlf;
    $hmtl .= 'This alternative message is in MIME 1.0 format.';
    $html .= $crlf;
  if($body ne '')
     {
       #------------------------------------------------------------------------
       $html .= $a_next_boundary;
       $html .= $charset.'; name="document.html"';
       $html .= $crlf;
       $html .= 'Content-Transfer-Encoding: quoted-printable';
       $html .= $crlf;
       $html .= $crlf;
       $html .= encode_qp($body);
     if($text ne '')
      {
       #-------------------------------------------------------------------------
       $html .= $a_next_boundary;
       $html .= $charset.'; name="document.txt"';
       $html .= $crlf;
       $html .= 'Content-Transfer-Encoding: quoted-printable';
       $html .= $crlf;
       $html .= $crlf;
       $html .= encode_qp($text);
      }
       $html .= $a_last_boundary;
       if(send(Hand,$html,0) eq undef){return(-1);} # -1 Can`t send to socket
       $html = '';
     }
   else
     {
       #-------------------------------------------------------------------------
       $html .= $a_next_boundary;
       $html .= $charset.'; name="document.txt"';
       $html .= $crlf;
       $html .= 'Content-Transfer-Encoding: quoted-printable';
       $html .= $crlf;
       $html .= $crlf;
       $html .= encode_qp($text);
       $html .= $a_last_boundary;
       if(send(Hand,$html,0) eq undef){return(-1);} # -1 Can`t send to socket
       $html = '';
     }
 if (%mole_attached_files)
  {
   my ($file,$ext,$type);
   my $cnt = 0;
   my $data;
   foreach $file (keys %mole_attached_files)
   {
    local *ATTCH;
    open (ATTCH,$mole_attached_files{$file}) or next;
    binmode (ATTCH);
    if(($file =~ m/^.*\.(.*)$/s))
     {
      $ext = $1;
     }
    else 
     {
      $ext = '';
     }
    $type = $MIMETYPES{$ext};
 if (($type eq '') or ($ext eq '')) { $type = 'application/octet-stream'; }
    #-----------------------------------------------------------------------------
    $html .= $next_boundary;
    $html .= 'Content-type: '.$type.'; name="'.$file.'"';
    $html .= $crlf;
    $html .= 'Content-Transfer-Encoding: base64';
    $html .= $crlf;
    $html .= 'Content-Disposition: attachment; filename="'.$file.'"';
    $html .= $crlf;
    $html .= $crlf;
    while($data = <ATTCH>)
    {
    $html .= encode_base64($data);
    if(send(Hand,$html,0) eq undef){return(-1);} # -1 Can`t send to socket
    $html = '';
    }
    close (ATTCH);
   }
  }
  #--------------------------------------------------------------------------------------------------------
  $html .= $last_boundary;
 }
 else
 {
 if($body ne '')
  {
   $html .= $crlf.$body;
  }
 else
  {
   $html .= $crlf.$text;
  }
 }
 $html .= $crlf.'.'.$crlf;
 if(send(Hand,$html,0) eq undef){return(-1);} # -1 Can`t send to socket
 %mole_attached_files = ();
 return(1);
}

$mail_program = find_mail_program();

return 1;