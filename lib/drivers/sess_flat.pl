############################################
# Flat Session Support for WebTools
# Powerd by www.proscriptum.com
#
# This is a part of WebTools module so
# WebTools privacy/copyright are applied
# and for this file!
############################################

@requestedFiles  = ();
$countOfReqFiles = 0;
$ptrInBuffer = 0;
$allFiles = 0;
$boundary = '';
$file_prefix = '';

sub reset_SF_cache
{
 @requestedFiles  = ();      # Buffer for requested files!
 $countOfReqFiles = 500;     # Maximum files into buffer.
 $ptrInBuffer = 0;           # Current pointer into buffer.
 $allFiles = 0;              # Global processed files up to now.
 $boundary = '|';
 $file_prefix = 'webtools_sess_';
}

# Init variables
reset_SF_cache();

sub read_SF_NextFiles
{
 *OD_FILE = shift(@_);
 my $path = shift(@_);
 my $cntFiles = shift(@_) || $countOfReqFiles;
 my $i;
 $ptrInBuffer = 0;
 @requestedFiles = ();
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 for ($i=0; $i<$cntFiles;$i++)
  {
   my $fn = readdir(OD_FILE);
   if($fn ne undef)
    {
     if((!($fn =~ /^\.$/s)) and (!($fn =~ /^\.\.$/s)))
      {
       my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= stat($path.$fn);
       $fn .= $boundary.$mtime;            # File name + modified time (Eg: passwd|990466880)
       push(@requestedFiles, $fn);
      }
    else
     {
      $i--;
     }
    }
   else
    {
     push(@requestedFiles, $fn);
     last;
    }
  }
 return(@requestedFiles);
}

sub reset_SF_cache
{
 @requestedFiles  = ();      # Buffer for requested files!
 $countOfReqFiles = 500;     # Maximum files into buffer.
 $ptrInBuffer = 0;           # Current pointer into buffer.
 $allFiles = 0;              # Global processed files up to now.
 $boundary = '|';
 $file_prefix = 'webtools_sess_';
}

sub get_SF_NextFile
{
 *OD_FILE = shift(@_);
 my $path = shift(@_);
 my $cntFiles = shift(@_) || $countOfReqFiles;
 if(($cntFiles == $ptrInBuffer) || ($allFiles == 0))
   {
    @requestedFiles = read_SF_NextFiles(OD_FILE,$path,$cntFiles);
   }
 my $fln = $requestedFiles[$ptrInBuffer++];
 $allFiles++;
 return($fln);
}

sub remove_SF_OldSessions
{
 my $path = shift(@_);
 my ($sessTime) = shift(@_) || time();
 reset_SF_cache();
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 opendir(ODFILE,$path);
 my $l='';
 my $tmpl = quotemeta($boundary);
 
 while($l = get_SF_NextFile(ODFILE,$path))
  {
   my ($fn,$modtime) = split(/$tmpl/,$l);
   if($fn =~ m/^$file_prefix/)
     {
      $modtime = int($modtime);
      if($modtime < $sessTime)
        {
         unlink($path.$fn);
        }
     }
  }
 closedir(ODFILE);
}

sub read_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);
 
 if($ses eq '') {return(undef);}
 
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;

 my $data = read_SF_lowlevel($path.$findSid);
 return($data);
}

sub find_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);
 
 if($ses eq '') {return(undef);}
 
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findFile = $path.$file_prefix.$ses;

 if(-e $findFile)
  {
   return($ses);
  }
 return('');
}

sub write_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);
 my ($data) = shift(@_);
 if($ses eq '') {return(undef);}
 
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;
 my $findFile = $path.$findSid;
 return(write_SF_lowlevel($findFile,$data));
}

sub create_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);
 
 if($ses eq '') {return(undef);}
 
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;
 my $findFile = $path.$findSid;
 if(-e $findFile)
  {
   unlink($findFile);
  }
 open(CSFLL,">".$findFile) or return(undef);
 close(CSFLL);
 return(1);
}

sub destroy_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);
 
 if($ses eq '') {return(undef);}
 
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;
 my $findFile = $path.$findSid;
 if(-e $findFile)
  {
   unlink($findFile);
   return(1);
  }
 return(0);
}

sub update_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);
 
 if($ses eq '') {return(undef);}
 
 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;
 my $findFile = $path.$findSid;
 my $dat = read_SF_File($findFile,$ses);
 if(-e $findFile)
  {
   destroy_SF_File($findFile,$ses);
  }
 write_SF_File($findFile,$ses,$dat);

 return(1);
}

sub read_SF_lowlevel
{
 my ($findSid) = shift(@_);
 open(RSFLL,$findSid) or return(undef);
 binmode(RSFLL);
 if(read(RSFLL,$dat,65535) eq undef)
   {
    $dat = undef;
   }
 close(RSFLL);
 return($dat);
}

sub write_SF_lowlevel
{
 my ($nFile,$data) = @_;
 my $dat = 1;
 my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= ();
 my $fl = 0;
 if(-e $nFile)
  {
   ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= stat($nFile);
   $fl = 1;
  }
 open(WSFLL,">".$nFile) or return(undef);
 binmode(WSFLL);
 if(!(print WSFLL $data))
   {
    $dat = undef;
   }
 close(WSFLL);
 if($fl) {utime ($atime,$mtime,$nFile);}
 return($dat);
}

sub osetflag_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);

 my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= ();

 if($ses eq '') {return(undef);}

 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;
 my $findFile = $path.$findSid;
 if(-e $findFile)
  {
   ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= stat($findFile);
   my $f = 350100000;   # 4 February 1981
   if($atime > 360100000)
    {
     utime ($f,$mtime,$findFile);
     return(1);
    }
   else
    {
     return(-1);  # Unaccessable (still locked)
    }
  }
}

sub csetflag_SF_File
{
 my $path = shift(@_);
 my ($ses) = shift(@_);

 my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= ();

 if($ses eq '') {return(undef);}

 if(!($path =~ m/\/$/s)) {$path .= '/';}
 
 my $findSid = $file_prefix.$ses;
 my $findFile = $path.$findSid;
 if(-e $findFile)
  {
   ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)= stat($findFile);
   my $f = time();   # 4 February 1981
   if($atime < 360100000)
    {
     utime ($f,$mtime,$findFile);
     return(1);
    }
   else
    {
     return(-1);  # Unaccessable (still locked)
    }
  }
}


1;