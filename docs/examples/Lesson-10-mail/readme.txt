~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!		                           	 Mail	 					!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                        

 This example will introduce last (raw) mail functions. Thay not required "sendmail" so you 
could use it when other mail program is not available. The only one prerequirement is: 
"nslookup" - Don't worry, be happy: these functions works good under Unix/Linux as good as they
do that and under Windows(NT/XP) :-)

Example:

*******************************
  1. Installation
*******************************

  Please make sub directory 'mail' into your WebTools/htmls and copy file: mail.whtml there.
Ok, now run mail.whtml:
 
 http://www.july.bg/cgi-bin/webtools/process.cgi?file=mail/mail.whtml

 where: "http://www.july.bg/"  is your host
        "cgi-bin"  is your perl script directory,
        and "webtools" is your WebTools directory!

 NOTE: process.cgi is a base (system) script for me (respective you :)
       YOU ALWAYS NEED TO USE IT!!! (IT IS YOUR Perl/HTML COMPILER :)

 NOTE: See that extension of script is .whtml
       process.cgi support follow extensions: .html .hml .whtml .cgihtml .cgi ,
       but with .whtml and .cgihtml you can use highlightings in UltraEdit 
       (nice text editor for programmers :-)


*******************************
  2. Example explanation
*******************************
  
  Now let look at source of 'mail.whtml':




*******************************
  3. Author
*******************************

 Julian Lishev,

 Sofia, Bulgaria,

 e-mail: julian@proscriptum.com