###########################################
# Perl`s Download Library
###########################################
# Written by Julian Lishev - Sofia 2001
# Ver 2.0
###########################################
use strict;      # Perl was here...

my %MIMETYPES = ('zip','application/zip','exe','application/octet-stream','doc','application/msword',
              'report','application/zip','mpga','audio/mpeg','mp3','audio/mpeg','gz','application/x-gzip',
              'gzip','application/x-gzip','xls','application/vnd.ms-excel');
my $kill_flag = 0;
my $lenght = 2048;             # Each print() will be limited of this size!
my $period = 1;
$webtools::loaded_functions = $webtools::loaded_functions | 256;
###########################################
# Download File
###########################################
sub download_file
{
 my ($filename,$speed) = @_;
 my ($name,$ext);
 if(($filename =~ m/^.*\.(.*)$/s))
   {
    $ext = $1;
   }
 else 
   {
    $ext = '';
   }
 my $type = $MIMETYPES{$ext};
 if (($type eq '') or($ext eq '')) { $type = 'application/octet-stream'; }
 if (downloader_SendFile($filename,$type,$speed))
   {
    return(1);                    # Done!
   }
 else { return (0); }             # Transfer interrupted...or Apache kill process!
 # If Apache start killing..., Mole get exit NOW! :-))))
}
###########################################
sub downloader_onApacheKill
{
 $kill_flag = 1;
}
###########################################
# Read and Send file to STDOUT
###########################################
sub downloader_SendFile
{
 my ($filename,$type,$speed) = @_;
 my $name;
 if($speed) {$speed = int($speed*1024);}
 if($filename =~ m/\//)
  {
   $filename =~ m/^.*\/(.*)$/;
   $name = $1;
  }
 else { $name = $filename; }

 local $SIG{'TERM'} = '\&downloader_onApacheKill';   # Don`t allow Apache to kill process!
 local $SIG{'QUIT'} = '\&downloader_onApacheKill';
 local $SIG{'PIPE'} = '\&downloader_onApacheKill';
 
 $kill_flag = 0;
 $| = 1;
 open(FH,$filename) or return(0);
 binmode(FH);
 binmode(STDOUT);
 
 print "MIME-Type: 1.0\n";
 print "Content-Disposition: filename=$name\n";
 print "Content-Transfer-Encoding: binary\n";
 print "Content-Type: ".$type.";name=$name\n\n";;
 my $buffer = '';
 
 if($speed){$lenght = downloader_setSpeed($speed);}
 while(1)
   {
    if($kill_flag == 1) { return(0);}  # Killed!
    my $result = read(FH,$buffer,$lenght);
    if($result == 0)
      {
       last;
      }
    if($result eq undef)               # Error!
      {
       close FH;
       return(0);
      }
    if(!(print STDOUT $buffer))
      {
       close FH;
       return(0);
      }
    if($speed){sleep($period);}
   }
 close FH;
 return(1);           		       # Done...
}
sub downloader_setSpeed
{
  my $speed=shift;

  return(int($speed*$period));
}
1;
############################################
# TODO: To show what part of code were
# downloaded before connection break down.
############################################