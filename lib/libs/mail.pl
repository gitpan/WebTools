#################################################
# This module was originally written by
# Krasimir Krystev (c) Mole Software 
#
# Library modified by: Svetoslav Marinov
#################################################
# subs: send_mail set_attached_files
#       remove_mail_attachment
#################################################
# send_mail(FROM,TO,SUBJECT,BODY,AS_HTML);
#################################################
require './conf/config.pl';
%mole_attached_files = ();
sub send_mail {
    use MIME::QuotedPrint;  
    local($from, $to, $subject, $messagebody, $is_html) = @_;
    if (index($to,'@') eq -1){return -1;}
    local($fromuser, $fromsmtp, $touser, $tosmtp);
    if ($messagebody =~ /\<html\>/is) { $is_html = 'yes'; }
    if ($is_html ne '') {
      if ($debug_mail ne 'on') {
        $messagebody =encode_qp($messagebody);
      }
    }
    $fromuser = $from;
    $touser = $to;

    $fromsmtp = (split(/\@/,$from))[1];
    $tosmtp = (split(/\@/,$to))[1];
    
    if ($debug_mail ne 'on'){
      real_send_mail($fromuser, $touser, $subject, $messagebody, $is_html);
    }else{ 
      if ($is_html eq ''){
        &writeMailToFile($mailsender_path,'.sent',"FROM:" . $fromuser."\n"."TO:" . $touser ."\n". "SUBJECT:" . $subject ."\n". "BODY:\n\n" . $messagebody. "\n");
      }else{
         &writeMailToFile($mailsender_path,'.html.sent',"<HTML>FROM:" . $fromuser. "<BR>TO:" . $touser. "<BR>SUBJECT:" . $subject. "<BR>BODY:<BR><BR>" . $messagebody. "<BR><BR></HTML>");
      }
    }
  %mole_attached_files = ();
  return (1); # that will be fixed later :-) !
}

sub set_mail_attachment {
  my ($original_file_name,$server_file_name) = @_;
  $original_file_name =~ s/.*(\/|\\)(.*)$/$2/s;
  if($original_file_name eq '') {$original_file_name = 'webtools_upload_'.(rand()*1000);}
  $mole_attached_files{$original_file_name} = $server_file_name;
}

sub remove_mail_attachment {
  my ($original_file_name) = @_;
  delete($mole_attached_files{$original_file_name});
}

sub real_send_mail {
    local($fromuser, $touser, $subject, $messagebody, $is_html) = @_;
    local($old_path) = $ENV{"PATH"};
    $ENV{"PATH"} = "";
    
    open (MAIL, "|$mail_program") || web_error("Error: Could Not Open Mail Program");
    $ENV{"PATH"} = $old_path;
    local $additional_text = "";
    if ($is_html ne '') {
      $additional_text='Content-Type: text/html;'."\n"."Content-Transfer-Encoding: quoted-printable" . "\n\n".'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' . "\n";    }else{
      if (%mole_attached_files){
        $additional_text='Content-Type: text/html;' . "\n" . "Content-Transfer-Encoding: quoted-printable" . "\n\n" . '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' . "\n";
        $is_html = 'yes';
        $messagebody =~ s/\n/\<BR\>/gi;
        $messagebody = encode_qp($messagebody);
      }else{ # no attached files
        $additional_text='Content-Type: text/plain;'."\n\t".'charset="koi8-r"'."\n";

     }
    }
    local $add_txt= '';

    if (%mole_attached_files){
      use MIME::Base64;
      $add_txt=
qq~MIME-Version: 1.0
Content-Type: multipart/mixed;
\tboundary="----=_NextPart_000_002D_01BFF273.74C9B440"

This is a multi-part message in MIME format.

------=_NextPart_000_002D_01BFF273.74C9B440
Content-Type: multipart/alternative;
\tboundary="----=_NextPart_001_002E_01BFF273.74D2DC00"


------=_NextPart_001_002E_01BFF273.74D2DC00
Content-Type: text/plain;
\tcharset="koi8-r"
Content-Transfer-Encoding: quoted-printable




------=_NextPart_001_002E_01BFF273.74D2DC00
~;
      $additional_text = $add_txt . $additional_text;
    }
    print MAIL "To: $touser\n";
    print MAIL "From: $fromuser\n";
    print MAIL "CC: $to_cc\n";
    print MAIL "BCC: $to_bcc\n";
    print MAIL "Subject: $subject\n";
    print MAIL "$additional_text\n";
    print MAIL "$messagebody\n";
    
    my $file;
    my $data;
    if ($add_txt ne ''){
       print MAIL "\n------=_NextPart_001_002E_01BFF273.74D2DC00--\n\n";
    }

    foreach $file (keys %mole_attached_files){
       
       $data = readAttach($mole_attached_files{$file});
       
       print MAIL "\n------=_NextPart_000_002D_01BFF273.74C9B440\n";
       print MAIL "Content-Type: application/octet-stream; name=\"$file\"\n";
       print MAIL "Content-Transfer-Encoding: BASE64\n";
       print MAIL "Content-Disposition: attachment; filename=\"$file\"\n\n";
       print MAIL encode_base64($data);
    }

      if (%mole_attached_files){
      print MAIL "\n\n------=_NextPart_000_002D_01BFF273.74C9B440--\n\n";
    }
    close (MAIL);
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
  web_error("Error: I can't find <B>sendmail</B> program!");
  return '';
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
    $webtools_gen_file_name = $temp_dir.'webtools_'.$file.$ext;

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
    return '' if ($filename eq ''); # if no file, no action -:) (c) Svetoslav
    local $/ = undef;
    my $data;
    open (FILE,$filename) or return('');
    binmode (FILE);
    $data = <FILE>;    
    close (FILE);
    
    return $data;
  }

$mail_program = find_mail_program();

return 1;

