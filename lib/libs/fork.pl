######################
# Unix/Win compatible
# fork() function!
######################
#####################################################################

# Copyright (c) 2001, Julian Lishev, Sofia 2001
# All rights reserved.
# This code is free software; you can redistribute
# it and/or modify it under the same terms 
# as Perl itself.

#####################################################################
############################################
# Complatable form of FORK for Unix AND Win!
############################################
sub ForkScript
{
 # Apache will try to kill that process, when pipes are closed!
 $SIG{'TERM'} = 'IGNORE';
 
 # flush_print(); -> That must be called before that function!!!

 # Break pipes to browser( Apache flush all data)
 close (STDOUT);
 close (STDIN);
 close (STDERR);

 ###################################
 # Making fork (this may be needful)
 ###################################
 local $PIT = 0;
 if(!($^O =~ m/Win/is))
   {
    eval {$PIT = fork();};
    if ($@ eq '')
     {
      if ($PIT)
        {
         exit;  # All doubts must disapear here!
        }
     }
   }
 
 ############################################
 # Do anything that will take very long time!
 ############################################
 return(1);
}

1;