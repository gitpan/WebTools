#################################################
# Set of IPs from where scripts can be executed!
#################################################

my @allowed_IPs = ();
open (IPF, $db_path.'ips.pl');
my @IPs = <IPF>;  # Load allowed IPs
close IPF;
foreach my $ip (@IPs)
 { 
  $ip =~ s/^(.*?)(#.*)$/$1/si;
  $ip =~ s/(\ |\n|\r|\t)//sg;
  if($ip) {push(@allowed_IPs,$ip);}
 }

#################################################
# Call this function to check whether calling
# IP mach your restrictions.
#################################################

sub Check_Remote_IP
{
 my $ip = shift(@_);

 foreach $l (@allowed_IPs)
  {
   $l =~ s/\./\\./sg;
   $l =~ s/\*/\\d{0,3}/sig;
   $l = '^'.$l.'$';
   if($ip =~ m/$l/s)
     {
      return(1);
     }
  }
 return(0);
}

1;