~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!	                              XReader example 				   		!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                        

 Xreader is template processor that proceed template(.jhtml) files. Evry pice of template file
could contain variables and/or SQL queries. But what actualy is template? Template is pice of
code (commonaly html) that contain variable information i.e. some part of this code can be replaced
with dynamic data, so one template can be used multiple times but with modifications.

Example:

*******************************
  1. Installation
*******************************

  Please make sub directory 'xread' into your WebTools/htmls and copy file: xr.whtml there. Also
make sub directory 'xread' into your WebTools/jhtml and copy file: xr.jhtml there.
Ok, now run xr.whtml:
 
 http://www.july.bg/cgi-bin/webtools/process.cgi?file=xread/xr.whtml 

 where: "http://www.july.bg/"  is your host
        "cgi-bin"  is your perl script directory,
        and "webtools" is your WebTools directory!

 NOTE: See that extension of script is .whtml
       process.cgi support follow extensions: .html .hml .whtml .cgihtml .cgi ,
       but with .whtml and .cgihtml you can use highlightings in UltraEdit 
       (nice text editor for programmers :-)

 NOTE: process.cgi is a base (system) script for me (respective you :)
       YOU ALWAYS NEED TO USE IT!!! (IT IS YOUR Perl/HTML COMPILER :)

*******************************
  2. Example explanation
*******************************
  
  Now let look at source of 'xr.whtml':

  require 'xreader.pl';
Before you are able to use templates first you need to include xreader library (see line above).

Also you will need to sql_connect() database you want to query (only in case you want to use SQL templates!)
  $dbh = sql_connect();

  xreader_dbh($dbh);
Function above tell to xreader to use $dbh as default database handler!

  $text = xreader(2,'xread/xr.jhtml',$sql_user_table);
This line actualy query template with number 2 of "xread/xr.jhtml" file and return as result substituted template!
Before continue you should explain how exacly work this function:

$proceed_template_value = xreader(Number_of_template,relative_path_to_template, array_of_values_for_template_variables);

Let see template number 2 from "xread/xr.jhtml" file:

<©N®2®1®®©>
Hello '<S©L:1:"select USER,ID from <§VAR§>":1:1:1:1:S©L>'<BR>
<S©LVAR:1:S©L>`s ID is: <S©L:2:"":1:1:2:1:S©L><BR>
<˜©˜>

"<©N®2®1®®©>" is begin boundary. It's syntax is: 
  
  <©N®number_of_template®1_or_0®if_previous_0_that_should_be_file_name®©>
You see that boundary has three fields:
 -First: number of template
 -Second: 1 or 0. If "1" data must be read from "this" file up to end boundary ("<˜©˜>"). If field is "0" 
then data must be read from external file (name is suplyed in third field)
 -Third: file name from where data should be read when "second" field is "0".

"<˜©˜>" that is end separator for all templates in ".jhtml" files!

"<S©L:1:"select USER,ID from <§VAR§>":1:1:1:1:S©L>" that is one SQL template (for more information please
read docs/xreader-legend.txt file).

"<S©LVAR:1:S©L>" SQL variable (for more information please read docs/xreader-legend.txt file).

"<§VAR§>" is simple template variable. When template is proceeding then all template variables are substituted
with array_of_values_for_template_variables (last parameter of xreader() function).

So first call to xreader function will transform template to:

<©N®2®1®®©>
Hello '<S©L:1:"select USER,ID from $sql_user_table":1:1:1:1:S©L>'<BR>
<S©LVAR:1:S©L>`s ID is: <S©L:2:"":1:1:2:1:S©L><BR>
<˜©˜>

where $sql_user_table on default is "webtools_users"

First call to xreader also will make one sql query to database and substitute SQL templates/variables with
respective values became from database.

Second call to xreader() is:

  $data = xreader(1,'xread/xr.jhtml',200,$text);

where:
  "1" is first template in "xread/xr.jhtml" file.
  "xread/xr.jhtml" ius name of template file
  "200" is value of first template variable in this template (number 1).
  $text is data returned from previous xreader() call and it is value for second template variable in first 
template (number 1).

As result of xreader() function we get substituted/proceeded template.
Visualy first template is a text shown into browser, and second template is actualy one table with red boreder!
For completeness I will show you and first templete of xr.jhtml file: 

<©N®1®1®®©>
<TABLE WIDTH="<§VAR§>" CELLSPACING="1" CELLPADDING="10" bgcolor="#A04040">
<TR>
    <TD bgcolor="#404040">
     <center><FONT SIZE="-1"><§VAR§></FONT></center>
    </TD>
</TR>
</TABLE>
<˜©˜>
 
Once again: Read docs/xreader-legend.txt file for more information!

*******************************
  3. Author
*******************************

 Julian Lishev,

 Sofia, Bulgaria,

 e-mail: julian@proscriptum.com