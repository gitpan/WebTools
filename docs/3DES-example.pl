###############################################
# Cript/EnCript Test Program by Julian Lishev
###############################################
# Don`t forgot to show the right path to module!
# use lib '......';
use TripleDES;

 $crpt = EncriptData("secret_credit_card=4557024001932895","Unhackable_password");
 print "My data now is crypted like: $crpt\n";

 $encrpt = DecriptData($crpt,"Unhackable_password");
 print "Now we read encripted value via password: $encrpt\n";
 
1;