#!/usr/local/bin/perl5

##++
##    JSprite
##    Sprite v.3.2
##    Last modified: August 22, 1998
##
##    Copyright (c) 1998, Jim Turner, from
##    Sprite.pm (c) 1995-1998, Shishir Gundavaram
##    All Rights Reserved
##
##    E-Mail: shishir@ora.com
##    E-Mail: jim.turner@lmco.com
##
##    Permission  to  use,  copy, and distribute is hereby granted,
##    providing that the above copyright notice and this permission
##    appear in all copies and in supporting documentation.
##
##    If you use Sprite for any cool (Web) applications, I would be 
##    interested in hearing about them. So, drop me a line. Thanks!
##--

#############################################################################

=head1 NAME

JSprite - Modified version of Sprite to manipulate text delimited flat-files 
as databases using SQL emulating Oracle.  The remaining documentation
is based on Sprite.

=head1 SYNOPSIS

  use JSprite;

  $rdb = new JSprite;

  $rdb->set_delimiter (-read  => '::')  ## OR: ('read',  '::');
  $rdb->set_delimiter (-write => '::')  ## OR: ('write', '::');
  $rdb->set_delimiter (-record => '\n')  ## OR: ('record', '::');

  $rdb->set_os ('Win95');

    ## Valid arguments (case insensitive) include:
    ##
    ## Unix, Win95, Windows95, MSDOS, NT, WinNT, OS2, VMS, 
    ## MacOS or Macintosh. Default determined by $^O.

  #$rdb->set_lock_file ('c:\win95\tmp\Sprite.lck', 10);
	$rdb->set_lock_file ('Sprite.lck', 10);

  $rdb->set_db_dir ('Mac OS:Perl 5:Data') || die "Can't access dir!\n";

  $data = $rdb->sql (<<Query);   ## OR: @data = $rdb->sql (<<Query);
      .
      . (SQL)
      .
  Query

  foreach $row (@$data) {        ## OR: foreach $row (@data) {
      @columns = @$row;          ## NO null delimited string -- v3.2
  }                              

  $rdb->xclose;
  $rdb->close ($database);       ## To save updated database

=head1 DESCRIPTION

Here is a simple database where the fields are delimited by double-colons:

  PLAYER=VARCHAR2(16)::YEARS=NUMBER::POINTS=NUMBER::REBOUNDS=NUMBER::ASSISTS=NUMBER::Championships=NUMBER
  ...
  Larry Bird::13::25::11::7::3
  Michael Jordan::14::29::6::5::5
  Magic Johnson::13::22::7::11::5
  ...

I<Note:> The first line must contain the field names (case insensitive),
and the Oracle datatype and length.  Currently, the only meaningful
datatypes are NUMBER and VARCHAR.  All other types are treated
the same as VARCHAR (Perl Strings, for comparisens).

=head1 Supported SQL Commands

Here are a list of the SQL commands that are supported by JSprite:

=over 5

=item I<select> - retrieves records that match specified criteria:

  select col1 [,col2] from database 
         where (cond1 OPERATOR value1) 
         [and|or (cond2 OPERATOR value2) ...] 
         order by col1 [,col2] 

The '*' operator can be used to select all columns.

The I<database> is simply the file that contains the data. If the file 
is not in the current directory, the path must be specified.  By
default, the actual file-name will end with the extension ".sdb".

Sprite does I<not> support multiple tables (commonly known as "joins").

Valid column names can be used where [cond1..n] and [value1..n] are expected, 
such as: 

I<Example 1>:

  select Player, Points from my_db
         where (Rebounds > Assists) 

I<Note:> Column names must not be Perl string or boolean operators, ie. (lt, 
	gt, eq, and, or, etc. and are case-insensitive.
	
The following SQL operators can be used: =, <, >, <=, >=, <>, 
is,  as well as Perl's special operators: =~ and !~.  
The =~ and !~ operators are used to 
specify regular expressions, such as: 

I<Example 2>:

  select * from my_db
         where (Name =~ /Bird$/i) 

Selects records where the Name column ends with "Bird" (case insensitive). 
For more information, look at a manual on regexps.

I<Note:> A path to a database can contain only the following characters:

  \w, \x80-\xFF, -, /, \, ., :

If you have directories with spaces or other 'invalid' characters, you 
need to use the I<set_db_dir> method.

=item I<update> - updates records that match specified criteria. 

  update database 
    set cond1 = (value1)[,cond2 = (value2) ...]
        where (cond1 OPERATOR value1)
        [and|or (cond2 OPERATOR value2) ...] 

I<Example>:

  update my_db 
	 set Championships = (Championships + 1) 
         where (Player = 'Larry Bird') 

  update my_db
         set Championships = (Championships + 1),
	     Years = (12)
         where (Player = 'Larry Bird')

=item I<delete> - removes records that match specified criteria:

  delete from database 
         where (cond1 OPERATOR value1) 
         [and|or (cond2 OPERATOR value2) ...] 

I<Example>:

  delete from my_db
         where (Player =~ /Johnson$/i) or
               (Years > 12) 

=item I<alter> - simplified version of SQL-92 counterpart

Removes the specified column from the database. The other standard SQL 
functions for alter table are also supported:

  alter table database drop (column-name [, column-name2...])

  alter table database add ([position] column-name datatype
  		[, [position2] column-name2 datatype2...] 
  		[primary key (column-name [, column-name2...]) ])

I<Examples>:

  alter table my_db drop (Years)

  alter table my_db add (Legend VARCHAR(40) default "value", Mapname CHAR(5))

  alter table my_db add (1 Maptype VARCHAR(40))

This example adds a new column as the 2nd column (0 for 1st column) of the 
table.  By default, new fields are added as the right-most (last) column of 
the table.  This is a JSprite Extension and is not supported by standard SQL.

  alter table my_db modify (Legend VARCHAR(40))

  alter table my_db modify (0 Legend default 1)

The last example moves the "Legend" column to the 1st column in the table and 
shifts the others over, and causes all subsequent records added to use a 
default value of "1" for the "Legend" field, if no value is inserted for it.
This "Position" field (zero in the example) is a JSprite extension and is not 
part of standard SQL.  

=item I<insert> - inserts a record into the database:

  insert into database 
         [(col1, col2, ... coln) ]
  values 
         (val1, val2, ... valn) 

I<Example>:

  insert into my_db 
         (Player, Years, Points, Championships) 
  values 
         ('Kareem Abdul-Jabbar', 21, 26, 6) 

You don't have to specify all of the fields in the database! Sprite also 
does not require you to specify the fields in the same order as that of 
the database. 

I<Note:> You should make it a habit to quote strings. 

=back

=head1 METHODS

Here are the available methods:

=over 5

=item I<set_delimiter>

The set_delimiter function sets the read and write delimiter for the
database. The delimiter is not limited to one character; you can have 
a string, and even a regexp (for reading only).  In JSprite,
you can also set the record seperator (default is newline).

I<Return Value>

None

=item I<set_os>

The set_os function can be used to notify Sprite as to the operating 
system that you're using. Default is determined by $^O.

I<Note:> If you're using Sprite on Windows 95/NT or on OS2, make sure
to use backslashes -- and NOT forward slashes -- when specifying a path 
for a database or to the I<set_db_dir> or I<set_lock_file> methods!

I<Return Value>

None

=item I<set_lock_file>

For any O/S that doesn't support flock (i.e Mac, Windows 95 and VMS), this
method allows you to set a lock file to use and the number of tries that
Sprite should try to obtain a 'fake' lock. However, this method is NOT 
fully reliable, but is better than no lock at all.

'Sprite.lck' (either in the directory specified by I<set_db_dir> or in 
the current directory) is used as the default lock file if one 
is not specified.

I<Return Value>

None

=item I<set_db_dir>

A path to a database can contain only the following characters: 

  \w, \x80-\xFF, -, /, \, ., :  

If your path contains other characters besides the ones listed above,
you can use this method to set a default directory. Here's an example:

  $rdb->set_db_dir ("Mac OS:Perl 5:Data");

  $data = $rdb->sql ("select * from phone.db");

Sprite will look for the file "Mac OS:Perl 5:Data:phone.db". Just to
note, the database filename cannot have any characters besides the one 
listed above!

I<Return Value>

  0 - Failure
  1 - Success

=item I<set_db_ext>

JSprite permits the user to specify an extension that is part
of the actual file name, but not part of the corresponding
table name.  The default is '.sdb'.

  $rdb->set_db_ext ('.sdb');


I<Return Value>

None

=item I<sql>

The sql function is used to pass a SQL command to this module. All of the 
SQL commands described above are supported. The I<select> SQL command 
returns an array containing the data, where the first element is the status. 
All of the other other SQL commands simply return a status.

I<Return Value>
  1 - Success
  0 - Error

=item I<commit>

The sql function is used to commit changes to the database.
Arguments:  file-name (usually the table-name) - the file
name to write the table to.  NOTE:  The path and file 
extension will be appended to it, ie:

  &rdb->commit('filename');

I<Return Value>
  1 - Success
  0 - Error

=item I<close>

The close function closes the file, and destroys the database object. You 
can pass a filename to the function, in which case Sprite will save the 
database to that file; the directory set by I<set_db_dir> is used as
the default.

I<Return Value>

None

=back

=head1 NOTES

Sprite is not the solution to all your data manipulation needs. It's fine 
for small databases (less than 1000 records), but anything over that, and 
you'll have to sit there and twiddle your fingers while Sprite goes 
chugging away ... and returns a few *seconds* or so later.

The main advantage of Sprite is the ability to develop and test 
prototype applications on personal machines (or other machines which do not 
have an Oracle licence or some other "mainstream" database) before releasing 
them on "production" machines which do have a "real" database.  This can all 
be done with minimal or no changes to your Perl code.

Another advantage of Sprite is that you can use Perl's regular expressions 
to search through your data. Yippee!

JSprite provides the ability to emulate basic database tables
and SQL calls via flat-files.  The primary use envisioned
for this is to permit website developers who can not afford
to purchase an Oracle licence to prototype and develop Perl 
applications on their own equipment for later hosting at 
larger customer sites where Oracle is used.  :-)

JSprite attempts to do things in as database-independent manner as possible, 
but where differences occurr, JSprite most closely emmulates Oracle, for 
example "sequences/autonumbering".  JSprite uses tiny one-line text files 
called "sequence files" (.seq).  and Oracle's "seq_file_name.NEXTVAL" 
function to insert into autonumbered fields.

=head1 ADDITIONAL JSPRITE-SPECIFIC FEATURES

JSprite supports Oracle sequences and functions.  The
currently-supported Oracle functions are "SYSTIME", NEXTVAL, and "NULL".  
Users can also "register" their own functions via the 
"fn_register" method.

=item I<fn_register>

Method takes 2 arguments:  Function name and optionally, a
package name (default is "main").

  $rdb->fn_register ('myfn','mypackage');
  
-or-

  JSprite::fn_register ('myfn',__PACKAGE__);

Then, you could say:

	insert into mytable values (myfn(?))
	
and bind some value to "?", which is passed to "myfn", and the return-value 
is inserted into the database.  You could also say (without binding):

	insert into mytable values (myfn('mystring'))
	
-or (if the function takes a number)-

	select field1, field2 from mytable where field3 = myfn(123) 
	
I<Return Value>

None

JSprite has added the SQL "create" function to 
create new tables and sequences.  

I<Examples:>

	create table table1 (
		field1 number, 
		field2 varchar(20), 
		field3 number(5,3)  default 3.143)

	create sequence sequence-name [increment by 1] start with 0

=head1 SEE ALSO

DBD::Sprite, Sprite, Text::CSV, RDB

=head1 ACKNOWLEDGEMENTS

I would like to thank the following, especially Rod Whitby and Jim Esten, 
for finding bugs and offering suggestions:

  Shishir Gundavaram  (shishir@ora.com)     (Original Sprite Author)
  Rod Whitby      (rwhitby@geocities.com)
  Jim Esten       (jesten@wdynamic.com)
  Dave Moore      (dmoore@videoactv.com)
  Shane Hutchins  (hutchins@ctron.com)
  Josh Hochman    (josh@bcdinc.com)
  Barry Harrison  (barryh@topnet.net)
  Lisa Farley     (lfarley@segue.com)
  Loyd Gore       (lgore@ascd.org)
  Tanju Cataltepe (tanju@netlabs.net)
  Haakon Norheim  (hanorhei@online.no)

=head1 COPYRIGHT INFORMATION
	
			JSprite Copyright (c) 1998-2000, Jim Turner
          Sprite Copyright (c) 1995-1998, Shishir Gundavaram
                      All Rights Reserved

  Permission  to  use,  copy, and distribute is hereby granted,
  providing that the above copyright notice and this permission
  appear in all copies and in supporting documentation.

=cut

###############################################################################

package JSprite;

require 5.002;

use vars qw($VERSION);

use Cwd;
use Fcntl; 
use File::DosGlob 'glob';

eval {require 'OraSpriteFns.pl';};

##++
##  Global Variables. Declare lock constants manually, instead of 
##  importing them from Fcntl.
##
use vars qw ($VERSION $LOCK_SH $LOCK_EX);
##--

$JSprite::VERSION = '5.20';
$JSprite::LOCK_SH = 1;
$JSprite::LOCK_EX = 2;

my $NUMERICTYPES = '^(NUMBER|FLOAT|DOUBLE|INT|INTEGER|NUM)$';       #20000224
my $STRINGTYPES = '^(VARCHAR2|CHAR|VARCHAR|DATE|LONG|BLOB|MEMO)$';

##++
##  Public Methods and Constructor
##--

sub new
{
    my $class = shift;
    my $self;

    $self = {
                commands     => 'select|update|delete|alter|insert|create|drop',
                column       => '[A-Za-z0-9\~\x80-\xFF][\w\x80-\xFF]+',
		_select      => '[\w\x80-\xFF\*,\s\~]+',
		path         => '[\w\x80-\xFF\-\/\.\:\~\\\\]+',
		table        => '',
		file         => '',
		ext          => '',      #JWT:ADD FILE EXTENSIONS.
		directory    => '',
		timestamp    => 0,
		_read        => ',',
		_write       => ',',
		_record      => "\n",    #JWT:SUPPORT ANY RECORD-SEPARATOR!
		fields       => {},
		fieldregex   => '',      #ADDED 20001218
		use_fields   => '',
		key_fields   => '',
		order        => [],
		types        => {},
		lengths      => {},
		scales       => {},
		defaults     => {},
		records      => [],
		platform     => 'Unix',
		fake_lock    => 0,
		default_lock => 'Sprite.lck',
		lock_file    => '',
		lock_handle  => '',
		default_try  => 10,
		lock_try     => '',
                lock_sleep   => 1,
		errors       => {},
		lasterror    => 0,     #JWT:  ADDED FOR ERROR-CONTROL
		lastmsg      => '',
		CaseTableNames  => 0,    #JWT:  19990991 TABLE-NAME CASE-SENSITIVITY?
		LongTruncOk  => 0,     #JWT: 19991104: ERROR OR NOT IF TRUNCATION.
		RaiseError   => 0,     #JWT: 20000114: ADDED DBI RAISEERROR HANDLING.
		silent       => 0,
		dirty			 => 0,     #JWT: 20000229: PREVENT NEEDLESS RECOMMITS.
		StrictCharComp => 0    #JWT: 20010313: FORCES USER TO PAD STRING LITERALS W/SPACES IF COMPARING WITH "CHAR" TYPES.
	    };

    $self->{separator} = { Unix  => '/',    Mac => ':',   #JWT: BUGFIX.
		   PC    => '\\\\', VMS => '/' };

    bless $self, $class;

    $self->initialize;
    return $self;
}

sub initialize
{
    my $self = shift;

    $self->define_errors;
    $self->set_os ($^O) if (defined $^O);
}

sub set_delimiter
{
    my ($self, $type, $delimiter) = @_;
    $type      ||= 'other';
    $delimiter ||= $self->{_read} || $self->{_write};

    $type =~ s/^-//;
    $type =~ tr/A-Z/a-z/;

    if ($type eq 'read') {
	$self->{_read} = $delimiter;
    } elsif ($type eq 'write') {
	$self->{_write} = $delimiter;
    } elsif ($type eq 'record') {    #JWT:SUPPORT ANY RECORD-SEPARATOR!
	###$delimiter =~ s/^\r//  if ($self->{platform} eq 'PC');  #20000403 (BINMODE HANDLES THIS!!!)
	$self->{_record} = $delimiter;
    } else {
	$self->{_read} = $self->{_write} = $delimiter;
    }

    return (1);
}

sub set_os
{
    my ($self, $platform) = @_;
    #$platform = 'Unix', return unless ($platform);  #20000403.
    return $self->{platform}  unless ($platform);    #20000403

    $platform =~ s/\s//g;

#    if ($platform =~ /^(?:OS2|(?:Win)?NT|Win(?:dows)?95|(?:MS)?DOS)$/i) {
#	$self->{platform} = '';      #20000403
    if ($platform =~ /(OS2|Win|DOS)/i) {  #20000403
	$self->{platform} = 'PC';
    } elsif ($platform =~ /^Mac(?:OS|intosh)?$/i) {
	$self->{platform} = 'Mac';
    } elsif ($platform =~ /^VMS$/i) {
	$self->{platform} = 'VMS';
    } else {
	$self->{platform} = 'Unix';
    }
    return (1);
}

sub set_db_dir
{
    my ($self, $directory) = @_;
    return (0) unless ($directory);

    stat ($directory);

    #if ( (-d _) && (-e _) && (-r _) && (-w _) ) {  #20000103: REMD WRITABLE REQUIREMENT!
    if ( (-d _) && (-e _) && (-r _) ) {
	$self->{directory} = $directory;
	return (1);
    } else {
	return (0);
    }
}

sub set_db_ext      #JWT:ADD FILE EXTENSIONS.
{
    my ($self, $ext) = @_;

    return (0) unless ($ext);

    stat ($ext);

	$self->{ext} = $ext;
	return (1);
}

sub get_path_info
{
    my ($self, $file) = @_;
    my ($separator, $path, $name, $full);

    $separator = $self->{separator}->{ $self->{platform} };

    ($path, $name) = $file =~ m|(.*?)([^$separator]+)$|o;

	$name =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!

    if ($path) {
	$full  = $file;
    } else {
	#$path  = $self->{directory} || fastcwd;
	$path  = $self->{directory};
	$path .= $separator;
	$full  = $path . $name;
    }
    return wantarray ? ($path, $name) : $full;
}

sub set_lock_file
{
    my ($self, $file, $lock_try) = @_;

    if (!$file || !$lock_try) {
	return (0);
    } else {
	$self->{lock_file} = $file;
	$self->{lock_try}  = $lock_try;
    
	return (1);
    }
}

sub lock
{
    my $self = shift;
    my $count;

    $self->{lock_file} ||= $self->{default_lock}; 
    $self->{lock_file}   = $self->get_path_info ($self->{lock_file});
    $self->{lock_try}  ||= $self->{default_try};

    local *FILE;

    $count = 0;

    while (++$count <= $self->{lock_try}) {	
	if (sysopen (FILE, $self->{lock_file}, 
		           O_WRONLY|O_EXCL|O_CREAT, 0644)) {

	    $self->{fake_lock}   = 1;
	    $self->{lock_handle} = *FILE;

	    last;
	} else {
	    select (undef, undef, undef, $self->{lock_sleep});
	}
    }

    return $self->{fake_lock};
}

sub unlock
{
    my $self = shift;

    if ($self->{fake_lock}) {

	close ($self->{lock_handle}) || return (0);
	unlink ($self->{lock_file})  || return (0);
	
	$self->{fake_lock}   = 0;
	$self->{lock_handle} = '';

    }

    return (1);
}

sub sql
{
    my ($self, $query) = @_;

    my ($command, $status);

    return wantarray ? () : -514  unless ($query);

	$self->{lasterror} = 0;
	$self->{lastmsg} = '';
    $query   =~ s/\n/ /gs;
    $query   =~ s/^\s*(.*?)\s*$/$1/;
    $command = '';

	if ($query =~ /^($self->{commands})/io)
	{
		$command = $1;
		$command =~ tr/A-Z/a-z/;    #ADDED 19991202!
		$status  = $self->$command ($query);
		if (ref ($status) eq 'ARRAY')
		{     #SELECT RETURNED OK (LIST OF RECORDS).
			#unshift (@$status, 1);

			return wantarray ? @$status : $status;
		}
		else
		{
			if ($status < 0)
			{             #SQL RETURNED AN ERROR!
				$self->display_error ($status);
				#return ($status);
				return wantarray ? () : $status;
			}
			else
			{                        #SQL RETURNED OK.
				return wantarray ? ($status) : $status;
			}
		}
	}
	else
	{
		return wantarray ? () : -514;
	}
}

sub display_error
{	
    my ($self, $error) = @_;

    $other = $@ || $! || 'None';

    print STDERR <<Error_Message  unless ($self->{silent});

Oops! Sprite encountered the following error when processing your request:

    $self->{errors}->{$error} ($errdetails)

Here's some more information to help you:

	file:  $self->{file}
    $other

Error_Message

#JWT:  ADDED FOR ERROR-CONTROL.

	$self->{lasterror} = $error;
	$self->{lastmsg} = "$error:" . $self->{errors}->{$error};
	$self->{lastmsg} .= '('.$errdetails.')'  if ($errdetails);  #20000114

	$errdetails = '';   #20000114
	die $self->{lastmsg}  if ($self->{RaiseError});  #20000114.

    return (1);
}

sub commit
{
    my ($self, $file) = @_;
    my ($status, $full_path);

    $status = 1;
    return $status  unless ($self->{dirty});

    if ($file) {
	$full_path = $self->get_path_info ($file);
	$full_path .= $self->{ext}  if ($self->{ext});  #JWT:ADD FILE EXTENSIONS.
	$status    = $self->write_file ($full_path);

	$self->display_error ($status) if ($status <= 0);
    }

	return undef  if ($status <= 0);   #ADDED 20000103
	$self->{dirty} = 0;
    return $status;
}

sub xclose
{
    my ($self, $file) = @_;
	
	$status = $self->commit($file);
    undef $self;

    return $status;
}

##++
##  Private Methods
##--

sub define_errors
{
    my $self = shift;
    my $errors;

    $errors = {};

    $errors->{'-501'} = 'Could not open specified database.';
    $errors->{'-502'} = 'Specified column(s) not found.';
    $errors->{'-503'} = 'Incorrect format in [select] statement.';
    $errors->{'-504'} = 'Incorrect format in [update] statement.';
    $errors->{'-505'} = 'Incorrect format in [delete] statement.';
    $errors->{'-506'} = 'Incorrect format in [add/drop column] statement.';
    $errors->{'-507'} = 'Incorrect format in [alter table] statement.';
    $errors->{'-508'} = 'Incorrect format in [insert] command.';
    $errors->{'-509'} = 'The no. of columns does not match no. of values.';
    $errors->{'-510'} = 'A severe error! Check your query carefully.';
    $errors->{'-511'} = 'Cannot write the database to output file.';
    $errors->{'-512'} = 'Unmatched quote in expression.';
    $errors->{'-513'} = 'Need to open the database first!';
    $errors->{'-514'} = 'Please specify a valid query.';
    $errors->{'-515'} = 'Cannot get lock on database file.';
    $errors->{'-516'} = 'Cannot delete temp. lock file.';
    $errors->{'-517'} = "Built-in function failed ($@).";
    $errors->{'-518'} = "Unique Key Constraint violated.";  #JWT.
    $errors->{'-519'} = "Field would have to be truncated.";  #JWT.
    $errors->{'-520'} = "Can not create existing table (drop first!).";  #20000225 JWT.
    $errors->{'-521'} = "Can not change datatype on non-empty table.";  #20000323 JWT.
    $errors->{'-522'} = "Can not decrease field-size on non-empty table.";  #20000323 JWT.

    $self->{errors} = $errors;

    return (1);
}

sub parse_expression
{
    my ($self, $query) = @_;
#print STDERR "-PARSE_EXPRESSION: at 1 query=$query=\n";
    return unless ($query);
    my ($column, @strings, %numopmap, %stropmap, $numops, $strops, $special);
	my ($colmlist) = join('|',@{$self->{order}});
	my ($psuedocols) = "CURVAL|NEXTVAL";

	unless ($colmlist =~ /\S/)
	{
		local (*FILE);
		local ($/) = $self->{_record};    #JWT:SUPPORT ANY RECORD-SEPARATOR!
		$self->{file} =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
		$thefid = $self->{file};
		open(FILE, $self->{file}) || return (-501);
		binmode FILE;         #20000404
		$colmlist = <FILE>;
		chomp ($colmlist);
		$colmlist =~ s/$self->{_read}/\|/g;
		@{$self->{order}} = split(/\|/, $colmlist);
		close FILE;
	}
    $column    = $self->{column};
    @strings   = ();

    %numopmap  = ( '=' => 'eq', '==' => 'eq', '>=' => 'ge', '<=' => 'le',
                   '>' => 'gt', '<'  => 'lt', '!=' => 'ne', '<>' => 'ne');
    %stropmap  = ( 'eq' => '==', 'ge' => '>=', 'le' => '<=', 'gt' => '>',
	           'lt' => '<',  'ne' => '!=' , '=' => '==');

    $numops    = join '|', keys %numopmap;
    $strops    = join '|', keys %stropmap;

    $special   = "$strops|and|or";
	#NOTE!:  NEVER USE ANY VALUE OF $special AS A COLUMN NAME IN YOUR TABLES!!

    ##++
    ##  The expression: "([^"\\]*(\\.[^"\\]*)*)" was provided by
    ##  Jeffrey Friedl. Thanks Jeffrey!
    ##--

#$query =~ s/\'\'/\\\'/g;    #CONVERT ALL '' TO \'.
#$query =~ s#\b($column)\s*($numops)\s*\'\'\'#$1 $2 \'\\\'#go;   #FIX "op '''..." TO "op '\'..."
#$query =~ s/([^\\])\'\'\'/$1\\\'\'/g;    #FIX "'''   " TO "\''   "
$query =~ s/\\\\/\x02/g;    #PROTECT "\\"
#$query =~ s/\\\'/\x03/g;    #PROTECT "", \", '', AND \'.
$query =~ s/\\\'|\'\'/\x03/g;   #20000201  #PROTECT "", \", '', AND \'.
#$query =~ s/\\\"|\"\"/\x04/g;   #REMOVED 20000303.

#print STDERR "-2: query=$query=\n";

my ($i, $j, $j2, $k);
while (1)
{
	$i = 0;
	$i = ($query =~ s|(\w)\s+not\s+like\s+|$1 !^ |i);
	$i = ($query =~ s|(\w)\s+like\s+|$1 =^ |i)  unless ($i);
	if ($i)
	{
		#if ($query =~ /(\^\s*["'])([^"\\]*(\\.[^"\\]*)*)/)
		#if ($query =~ /(\^\s*)(["'])(.*?)\2/)
		if ($query =~ /([\=\!]\^\s*)(["'])(.*?)\2/)  #20001010
		{
			$j = "$1$2";   #EVERYTHING BEFORE THE QUOTE (DELIMITER), INCLUSIVE
			$i = $3;       #THE STUFF BETWEEN THE QUOTES.
			my $iquoted = $i;    #ADDED 20000816 TO FIX "LIKE 'X.%'" (X\.%)!
			$iquoted =~ s/([\\\|\(\)\[\{\^\$\*\+\?\.])/\\$1/g;
			my ($k) = "\^$iquoted\$";
			$k =~ s/^\^%//;
			$k =~ s/%\$$//;
			$j2 = $j;
			#$j2 =~ s/^\^/~/;   #CHANGE SPECIAL OPERATORS (=^ AND !^) BACK TO (=~ AND !~).
			$j2 =~ s/^(.)\^/$1~/;   #20001010 CHANGE SPECIAL OPERATORS (=^ AND !^) BACK TO (=~ AND !~).
			$k =~ s/_/./g;
			$query =~ s/\Q$j$i\E/$j2$k/;
		}
	}
	else
	{
		last;
	}
}
#print STDERR "-3: query=$query=\n";
	
    #$query =~ s/([!=][~\^])\s*(m)?([^\w;\s])([^\3\\]*(?:\\.[^\3\\]*)*)\3(i)?/

	#THIS REGEX LOOKS FOR USER-DEFINED FUNCTIONS FOLLOWING "=~ OR !~ (LIKE), 
	#FINDS THE MATCHING CLOSE PARIN(IF ANY), AND SURROUNDS THE FUNCTION AND 
	#IT'S ARGS WITH AN "&", A DELIMITER LATER USED TO EVAL IT.
	
	1 while ($query =~ s|([!=][~\^])\s*([a-zA-Z_]+)(.*)$|
			my ($one, $two, $three) = ($1, $2, $3);
			my ($parincnt) = 0;
			my (@lx) = split('', $three);
			my ($i);
			
			for ($i=0;$i<=length($three);$i++)
			{
				++$parincnt  if ($lx[$i] eq '(');
				last  unless ($parincnt);
				--$parincnt  if ($lx[$i] eq ')');
			}
			"$one ".'&'."$two".substr($three,0,$i).'&'.
					substr($three,$i);
	|e);

	#THIS REGEX HANDLES ALL OTHER LIKE AND PERL "=~" AND "!~" OPERATORS.
#print STDERR "-4: query=$query=\n";

    $query =~ s%([!=][~\^])\s*(m)?(.)([^\3]*?)\3(i)?%
	           my ($m, $i, $delim, $four, $one) = ($2, $5, $3, $4, $1);
                   $m ||= ''; $i ||= '';
					$m = 'm'  unless ($delim eq '/');
					my ($three) = $delim;
                    push (@strings, "$m$delim$four$three$i");
                   "$one *$#strings";
               %ge;
    #$query =~ s|(['"])([^\1\\]*(?:\\.[^\1\\]*)*)\1|
    $query =~ s|(["'])(.*?)\1|
                   push (@strings, "$1$2$1"); "*$#strings";
 	       |ge;

	$query =~ s/\x03/\'/g;   #RESTORE PROTECTED SINGLE QUOTES HERE.
	#$query =~ s/\x04/\"/g;   #RESTORE PROTECTED DOUBLE QUOTES HERE.   #REMOVED 20000303.
	$query =~ s/\x02/\\/g;   #RESTORE PROTECTED SLATS HERE.
#print STDERR "-6: query=$query=\n";

	for $i (0..$#strings)
	{
		$strings[$i] =~ s/\x03/\\\'/g; #RESTORE PROTECTED SINGLE QUOTES HERE.
		#$strings[$i] =~ s/\x04/\"/g;   #RESTORE PROTECTED DOUBLE QUOTES HERE.   #REMOVED 20000303.
		$strings[$i] =~ s/\x02/\\/g;   #RESTORE PROTECTED SLATS HERE.
	}

	if ($query =~ /^($column)$/)
	{
		$i = $1;
		$query = '&' . $i  unless ($i =~ $colmlist);
	}

#print STDERR "-15: query=$query=\n";
    $query =~ s#\b($column)\s*($numops)\s*\*#$1 $numopmap{$2} \*#go;
    $query =~ s#\b($column)\s*($numops)\s*\'#$1 $numopmap{$2} \'\'#go;
#print STDERR "-16: query=$query=\n";
    $query =~ s#\b($column)\s*($numops)\s*($colmlist)#$1 $numopmap{$2} $3#go;
    #$query =~ s#\b($column)\s*($numops)\s*($column(?:\(.*?\))?)#$1 $numopmap{$2} $3#go;
    $query =~ s%\b($column\s*(?:\(.*?\))?)\s+is\s+null%$1 eq ''%ig;
#print STDERR "-17: query=$query=\n";
    $query =~ s%\b($column\s*(?:\(.*?\))?)\s+is\s+not\s+null%$1 ne ''%ig;
    #$query =~ s%\b($column)\s*(?:\(.*?\))?)\s*($numops)\s*CURVAL%$1 $2 &pscolfn($self,$3)%g;
    $query =~ s%($column)\s*($numops)\s*($column\.(?:$psuedocols))%"$1 $2 ".&pscolfn($self,$3)%eg;
#print STDERR "-19: query=$query=\n";
    $query =~ s%\b($column\s*(?:\(.*?\))?)\s*($numops)\s*($column\s*(?:\(.*?\))?)%
		my ($one,$two,$three) = ($1,$2,$3);
		$one =~ s/\s+$//;
#print STDERR "-20a: 1=$one= 2=$two= 3=$three=\n";
		if ($one =~ /NUM\s*\(/ || ${$self->{types}}{"\U$one\E"} =~ /$NUMERICTYPES/i)
		{
			$two =~ s/^($strops)$/$stropmap{$two}/;
#print STDERR "-20N: 1=$one= 2=$two= 3=$three= tp=".${$self->{types}}{"\U$one\E"};
#print "-20N: 1=$one= 2=$two= 3=$three= tp=".${$self->{types}}{"\U$one\E"};
			"$one $two $three";
		}
		else
		{
#print "-20C: 1=$1= 2=$2= 3=$3= tp=".${$self->{types}}{"\U$one\E"};
#print STDERR "-20C: 1=$1= 2=$2= 3=$3= tp=".${$self->{types}}{"\U$one\E"};
			"$one $numopmap{$two} $three";
		}
	 %eg;
#print STDERR "-21A: query=$query=\n";

# (JWT 8/8/1998) $query =~ s|\b($column)\s+($strops)\s+(\d+)|$1 $stropmap{$2} $3|gio;
	$query =~ s|\b($column)\s*($strops)\s*(\d+)|$1 $stropmap{$2} $3|gio;
#print STDERR "-21B: query=$query=\n";

	my $ineqop = '!=';
	$query =~ s!\b($column)\s*($strops)\s*(\*\d+)!
		my ($one,$two,$three) = ($1,$2,$3);
		$one =~ s/\s+$//;
		my $res;
		if ($one =~ /NUM\s*\(/ || ${$self->{types}}{"\U$one\E"} =~ /$NUMERICTYPES/i)
		{
#print STDERR "\n-21N: BEF: 1=$one= 2=$two= 3=$three= tp=".${$self->{types}}{"\U$one\E"};
			my ($opno) = undef;    #NEXT 18 LINES ADDED 20010313 TO CAUSE STRING COMPARISENS W/NUMERIC FIELDS TO RETURN ZERO, SINCE PERL NON-NUMERIC STRINGS RETURN ZERO.
			if ($three =~ /^\*\d+/)
			{
				$opno = substr($three,1);
				$opno = $strings[$opno];
				$opno =~ s/^\'//;
				$opno =~ s/\'$//;
			}
			else
			{
				$opno = $three;
			}
#print STDERR "\n-21Nc: opno=$opno=\n";
			unless ($opno =~ /^[\+\-\d\.][\d\.Ex\+\-\_]*$/)  #ARGUMENT IS A VALID NUMBER.
			{
			#	$res = '0';
			#	$res = '1'  if ($two eq $ineqop);
#print STDERR "\n-21Nd: AFT: 1=$one= 2=$two= 3=$three= opno=$opno=\n";
				$res = "$one $two '0'";
			}
			else
			{
				$two =~ s/^($strops)$/$stropmap{$two}/  unless ($opno eq "0");
				$res = "$one $two $three";
#print STDERR "\n-21Ne: AFT: 1=$one= 2=$two= 3=$three= opno=$opno=\n";
			}
		}
		elsif ($self->{StrictCharComp} == 0 && ${$self->{types}}{"\U$one\E"} eq 'CHAR')
		{
			my ($opno) = undef;    #NEXT 18 LINES ADDED 20010313 TO CAUSE STRING COMPARISENS W/NUMERIC FIELDS TO RETURN ZERO, SINCE PERL NON-NUMERIC STRINGS RETURN ZERO.
			if ($three =~ /^\*\d+/)
			{
				$opno = substr($three,1);
				my $opstr = $strings[$opno];
				$opstr =~ s/^\'//;
				$opstr =~ s/\'$//;
				$strings[$opno] = "'" . sprintf(
							'%-'.${$self->{lengths}}{"\U$one\E"}.'s',
							$opstr) . "'";
			}
#print STDERR "-21C: 1=$one= 2=$two= 3=$three= tp=".${$self->{types}}{"\U$one\E"};
			$res = "$one $two $three";
		}
		else
		{
#print STDERR "-21V: 1=$one= 2=$two= 3=$three= tp=".${$self->{types}}{"\U$one\E"};
			$res = "$one $two $three";
		}
		$res;
		!eg;

#print STDERR "-22 query=$query=\n";
	#NOTE!:  NEVER USE ANY VALUE OF $special AS A COLUMN NAME IN YOUR TABLES!!
	#20000224 ADDED "\b" AFTER "$special)" 5 LINES BELOW!
	$query =~ s!\b(($colmlist))\b!
                   my $match = $1;
						$match =~ tr/a-z/A-Z/;
#print "-23: MATCH=$match=\n";
                   ($match =~ /\b(?:$special)\b/io) ? "\L$match\E"    : 
                                                    "\$_->{$match}"
               !gei;
	$query =~ s/ (and|or|not) / \L$1\E /ig;   #ADDED 20001011 TO FIX BUG THAT DIDN'T ALLOW UPPER-CASE BOOLOPS! 20001215: SPACES ADDED TO PREVENT "$_->{MandY}" MANGLE!
    $query =~ s|[;`]||g;
    $query =~ s#\|\|#or#g;
    $query =~ s#&&#and#g;

	$query =~ s|(\d+)\s*($strops)\s*(\d+)|$1 $stropmap{$2} $3|gio;   #ADDED 20010313 TO MAKE "1=0" CONDITION EVAL WO/ERROR.
    $query =~ s|\*(\d+)|$strings[$1]|g;
    
	#THIS REGEX EVALS USER-FUNCTION CALLS FOLLOWING "=~" OR "!~".
#print "-25: query=$query=\n";
	$query =~ s@([!=][~\^])\s*m\&([a-zA-Z_]+[^&]*)\&@
			my ($one, $two) = ($1, $2);
			
			$one =~ s/\^/\~/;
			my ($res) = eval($two);
			$res =~ s/^\%//;
			$res =~ s/\%$//;
			my ($rtn);
			foreach my $i ('/',"'",'"','|')
			{
				unless ($res =~ m%$i%)
				{
					$rtn = "$one m".$i.$res.$i;
					last;
				}
			}
			$rtn;
	@eg;

    return $query;
}

sub check_columns
{
    my ($self, $column_string) = @_;
    my ($status, @columns, $column);

    $status  = 1;
$column =~ tr/a-z/A-Z/  if (defined $column);   #JWT
$column_string =~ tr/a-z/A-Z/;   #JWT
$self->{use_fields} = $column_string;    #JWT
    @columns = split (/,/, $column_string);

    foreach $column (@columns) {
	#$status = 0 unless ($self->{fields}->{$column});  #20000114
		unless ($self->{fields}->{$column})
		{
			$errdetails = $column;
			$status = 0;
		}
	}

    return $status;
}

sub parse_columns
{
    my ($self, $command, $column_string, $condition, $values, 
			$ordercols, $descorder, $fields, $distinct) = @_;
    my ($i, $j, $k, $rowcnt, $status, @columns, $single, $loop, $code, $column);
	my (%colorder, $rawvalue);
#print "-parse_columns: at=".join('|',@_)."= distinct=$distinct=\n";
	local $results = undef;

	my (@keyfields) = split(',', $self->{key_fields});  #JWT: PREVENT DUP. KEYS.
	my (%valuenames);  #ADDED 20001218 TO ALLOW FIELD-NAMES AS RIGHT-VALUES.

	foreach $i (keys %$values)
	{
		$valuenames{$i} = $values->{$i};
		$values->{$i} =~ s/^\'(.*)\'$/my ($stuff) = $1; 
				$stuff =~ s|\'|\\\'|g;
		$stuff =~ s|\\\'\\\'|\\\'|g;
				"'" . $stuff . "'"/e;
		$values->{$i} =~ s/^\'$//;      #HANDLE NULL VALUES.
		$values->{$i} =~ s/\n//g;       #REMOVE LFS ADDED BY NETSCAPE TEXTAREAS!
		$values->{$i} =~ s/\r /\r/g;    #20000108: FIX LFS PREV. CONVERTED TO SPACES!
		$values->{$i} = "''"  unless ($values->{$i} =~ /\S/);
	}
    local $SIG{'__WARN__'} = sub { $status = -510; $errdetails = "$_[0] at ".__LINE__ };
    local $^W = 0;
	local ($_);
$| = 1;
    $status  = 1;
    $results = [];
    @columns = split (/,/, $column_string);
    #$single  = ($#columns) ? $columns[$[] : $column_string;
    $single  = ($#columns) ? $columns[$#columns] : $column_string;
	$rowcnt = 0;

	my (@these_results);
	$fieldregex = $self->{fieldregex};
    for ($loop=0; $loop < scalar @{ $self->{records} }; $loop++)
	{
		next unless (defined $self->{records}->[$loop]);    #JWT: DON'T RETURN BLANK DELETED RECORDS.
		$_ = $self->{records}->[$loop];
#foreach my $xxx (keys(%{$_})) {print STDERR "-value($xxx) =$_->{$xxx}=\n";};
#print STDERR "->>>>> condition=$condition=\n";
#print "<BR> condition=$condition=\n";
		$@ = '';
		if ( !$condition || (eval $condition) ) {
#print "<BR>-- CONDITION RETURNED TRUE! res=$@=\n";
#print STDERR "-!!!!!- CONDITION RETURNED TRUE!\n";
		    if ($command eq 'select')
		    {
				if ($fields)
				{
					@these_results = ();
					for (my $i=0;$i<=$#{$fields};$i++)
					{
						push (@these_results, eval $fields->[$i]);
					}
					push (@$results, [ @these_results ]);
				}
				else
				{
					push (@$results, [ @$_{@columns} ]);
				}
		    } 
		    elsif ($command eq 'update') {
			$code = '';
			my ($matchcnt) = 0;
			my (@valuelist) = keys(%$values);
			my ($dontchkcols) = '('.join('|',@valuelist).')';
			foreach $i (@valuelist)
			{
				for ($j=0;$j<=$#keyfields;$j++)
				{
					if ($i eq $keyfields[$j])
					{
K: 
						for ($k=0;$k < scalar @{ $self->{records} }; $k++)
						{
							$rawvalue = $values->{$i};
							$rawvalue =~ s/^\'(.*)\'\s*$/$1/;
							if ($self->{records}->[$k]->{$i} eq $rawvalue)
							{
								foreach $jj (@keyfields)
								{
									unless ($jj =~ /$dontchkcols/)
									{
										next K  
											unless ($self->{records}->[$k]->{$jj} 
											eq $_->{$jj});
									}
								}
								goto MATCHED1;
							}
						}
						goto NOMATCHED1;
MATCHED1: ;
						++$matchcnt;
					}
				}
			}
			return (-518)  if ($matchcnt && $matchcnt > $#valuelist);   #ALL KEY FIELDS WERE DUPLICATES!
NOMATCHED1:
			$self->{dirty} = 1;
			foreach $jj (@columns)  #JWT 19991104: FORCE TRUNCATION TO FIT!
			{
				$rawvalue = $values->{$jj};
				#if ($rawvalue =~ /^[_a-zA-Z]/)  #NEXT 5 LINES ADDED 20000516 SO FUNCTIONS WILL WORK IN UPDATES!
				if ($valuenames{$jj} =~ /^[_a-zA-Z]/)  #NEXT 5 LINES ADDED 20000516 SO FUNCTIONS WILL WORK IN UPDATES!
				{
					unless ($self->{fields}->{$valuenames{$jj}})  #ADDED TEST 20001218 TO ALLOW FIELD-NAMES AS RIGHT-VALUES.
					{
						$rawvalue = &chkcolumnparms($valuenames{$jj});
						$rawvalue = eval $rawvalue;   #FUNCTION EVAL 3
						return (-517)  if ($@);
					}
					else
					{
						$rawvalue = $_->{$valuenames{$jj}};
					}
				}
				else
				{
					$rawvalue =~ s/^\'(.*)\'\s*$/$1/  if ($values->{$jj} =~ /^\'/);
				}
				#if (${$self->{types}}{$jj} =~ /$NUMERICTYPES/)  #CHGD TO NEXT LINE 20010313.
				if (length($rawvalue) > 0 && ${$self->{types}}{$jj} =~ /$NUMERICTYPES/)
				{
					$k = sprintf(('%.'.${$self->{scales}}{$jj}.'f'), 
							$rawvalue);
				}
				else
				{
					$k = $rawvalue;
				}
				$rawvalue = substr($k,0,${$self->{lengths}}{$jj});
				unless ($self->{LongTruncOk} || $rawvalue eq $k || 
						(${$self->{types}}{$jj} eq 'FLOAT'))
				{
					$errdetails = "$jj to ${$self->{lengths}}{$jj} chars";
					return (-519);   #20000921: ADDED (MANY PLACES) LENGTH TO ERRDETAILS "(fieldname to ## chars)"
				}
				if ((${$self->{types}}{$jj} eq 'FLOAT') 
						&& (int($rawvalue) != int($k)))
				{
					$errdetails = "$jj to ${$self->{lengths}}{$jj} chars";
					return (-519);
				}
				if (${$self->{types}}{$jj} eq 'CHAR')
				{
					$values->{$jj} = "'" . sprintf(
							'%-'.${$self->{lengths}}{$jj}.'s',
							$rawvalue) . "'";
				}
				#elsif (${$self->{types}}{$jj} !~ /$NUMERICTYPES/)  #CHGD. TO NEXT 20010313.
				elsif (!length($rawvalue) || ${$self->{types}}{$jj} !~ /$NUMERICTYPES/)
				{
					$values->{$jj} = "'" . $rawvalue . "'";
				}
				else
				{
					$values->{$jj} = $rawvalue;
				}
			}
			map { $code .= qq|\$_->{'$_'} = $values->{$_};| } @columns;
	                eval $code;
					return (-517)  if ($@);
		    } elsif ($command eq 'add') {
				$_->{$single} = '';   #ORACLE DOES NOT SET EXISTING RECORDS TO DEFAULT VALUE!
	
		    } elsif ($command eq 'drop') {
			delete $_->{$single};
		    }
			++$rowcnt;
		}
		elsif ($@)   #ADDED 20010313 TO CATCH SYNTAX ERRORS.
		{
			$errdetails = "Condition failed ($@) in condition=$condition!";
#print STDERR "\n-!!!!!!!!!!! CONDITION FAILED, AT=$@=\n";
			return -503  if ($command eq 'select');
			return -505  if ($command eq 'delete');
			return -504;
		}
    }

    if ($status <= 0)
	{
		return $status;
	}
	elsif ( $command ne 'select' )
	{
		return $rowcnt;
    } else {
#print "-???- dist=$distinct=\n";
		if ($distinct)   #THIS IF ADDED 20010521 TO MAKE "DISTINCT" WORK.
		{
			my (%disthash);
			for (my $i=0;$i<=$#$results;$i++)
			{
				++$disthash{join("\x02",@{$results->[$i]})};
			}
			@$results = ();
			foreach my $i (keys(%disthash))
			{
				push (@$results, [split(/\x02/, $i)]);
#print "-results=$i=\n";			
			}
		}
		if (@$ordercols)
		{
			$rowcnt = 0;
			my ($mysep) = "\x02";
			$mysep = "\xFF"  if ($descorder);
			@SA = ();
			$i = 0;
			#for (0..$#{$self->{order}})
			for (0..$#columns)
			{
				#$colorder{${$self->{order}}[$_]} = $_;
				$colorder{$columns[$_]} = $_;
			}
			for (0..$#$results)
			{
	    			next unless (defined $self->{records}->[$_]);

				#$SA[$i] = ' ' x (40x($#$ordercols+1));
				#$i = 0;
				foreach $j (@$ordercols)
				{
					$j =~ tr/a-z/A-Z/;
					$k = $colorder{$j};
					if (${$self->{types}}{$j} eq 'FLOAT' || ${$self->{types}}{$j} eq 'DOUBLE')
					{
						#$SA[$i] .= sprintf('%'.${$self->{lengths}}{$j}.'s',$self->{records}->[$_]->{$j});
						$SA[$i] .= sprintf('%'.${$self->{lengths}}{$j}.${$self->{scales}}{$j}.'e',${$results}[$_]->[$k]);
						#$SA[$i] .= $self->{records}->[$_]->{$j} . $mysep;
					}
					#elsif (${$self->{types}}{$j} =~ /$NUMERICTYPES/)  #CHGD TO NEXT LINE 20010313.
					elsif (length (${$results}[$_]->[$k]) > 0 && ${$self->{types}}{$j} =~ /$NUMERICTYPES/)
					{
						#$SA[$i] .= sprintf('%'.${$self->{lengths}}{$j}.'s',$self->{records}->[$_]->{$j});
						$SA[$i] .= sprintf('%'.${$self->{lengths}}{$j}.${$self->{scales}}{$j}.'f',${$results}[$_]->[$k]);
						#$SA[$i] .= $self->{records}->[$_]->{$j} . $mysep;
					}
					else
					{
						$SA[$i] .= ${$results}[$_]->[$k] . $mysep;
					}
####select * from medm_users where fn like 'j%' order by (ln,fn) desc
					++$k;
				}
				$SA[$i] .= '|' . $_;
				++$i;
			}
			@SSA = sort {$a cmp $b} @SA;  #SORT 'EM!
			@SSA = reverse(@SSA)  if ($descorder);
			@SA = ();
			for (0..$#SSA)
			{
				#$SA[$_] = substr($SSA[$_],(40*($#$ordercols+1)));
				@l = split(/\|/, $SSA[$_]);
				$SA[$_] = $l[$#l];
				++$rowcnt;
			}
			@SSA = @$results;
			$i = $$results[0];
			for (0..$#SA)
			{
				$$results[$_] = $SSA[$SA[$_]];
			}
			##???@$results = ($i,@$results);
		}
		unshift (@$results, $rowcnt);
		return $results;
    }
}

sub check_for_reload
{
    my ($self, $file) = @_;
    my ($table, $path, $status);

    return unless ($file);

	if ($file =~ /^DUAL$/i)  #ADDED 20000306 TO HANDLE ORACLE'S "DUAL" TABLE!
	{
		undef %{ $self->{types} };
		undef %{ $self->{lengths} };
		$self->{use_fields} = 'DUMMY';
		$self->{key_fields} = 'DUMMY';   #20000223 - FIX LOSS OF KEY ASTERISK ON ROLLBACK!
		${$self->{types}}{DUMMY} = 'VARCHAR2';
		${$self->{lengths}}{DUMMY} = 1;
		${$self->{scales}}{DUMMY} = 1;
		$self->{order} = [ 'DUMMY' ];
		$self->{fields}->{DUMMY} = 1;
		undef @{ $self->{records} };
		$self->{records}->[0] = {'DUMMY' => 'X'};
		return (1);
	}

    ($path, $table) = $self->get_path_info ($file);
	#$table =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});
    $file   = $path . $table;  #  if ($table eq $file);
	$file .= $self->{ext}  if ($self->{ext});  #JWT:ADD FILE EXTENSIONS.
	#$file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});
    $status = 1;

	my (@stats) = stat ($file);
    if ( ($self->{table} ne $table) || ($self->{file} ne $file
    		|| $self->{timestamp} != $stats[9]) ) {
	#stat ($file);
	if ( (-e _) && (-T _) && (-s _) && (-r _) ) {

	    $self->{table} = $table;
		#$file .= $self->{ext}  if ($self->{ext});  #JWT:ADD FILE EXTENSIONS.
	    $self->{file}  = $file;
	    $status        = $self->load_database ($file);
		$self->{timestamp} = $stats[9];
	} else {
		$errdetails = $file;   #20000114
	    $status = 0;
	}
    }

	$errdetails = $file  if ($status == 0);   #20000114
    return $status;
}

sub rollback
{
    my ($self) = @_;
    my ($table, $path, $status);

	my (@stats) = stat ($self->{file});
	
	if ( (-e _) && (-T _) && (-s _) && (-r _) )
	{
	    $status = $self->load_database ($self->{file});
		$self->{timestamp} = $stats[9];
	}
	else 
	{
	    $status = 0;
	}
	$self->{dirty} = 0;
	return $status;
}

sub select
{
    my ($self, $query) = @_;
    my ($i, @l, $regex, $path, $columns, $table, $extra, $condition, 
			$values_or_error);
	my (@ordercols) = ();
#print STDERR "-select: query=$query=\n";
#print STDERR "-select: query=$query=\n";
    $regex = $self->{_select};
    $path  = $self->{path};
$fieldregex = $self->{fieldregex};

	my $distinct;   #NEXT 2 ADDED 20010521 TO ADD "DISTINCT" CAPABILITY!
	$distinct = 1  if ($query =~ /^select\s+distinct/);
	$query =~ s/^select\s+distinct(\s+\w|\s*\(|\s+\*)/select $1/i;

	#HANDLE SELECTS WITH JUST FIELD NAMES (NO FUNCTIONS) FAST.

	if ($query =~ /^select\s+                         # Keyword
                    ($regex)\s+                       # Columns
                    from\s+                           # 'from'
                    ($path)(.*)$/iox)
	{           
		($columns, $table, $extra) = ($1, $2, $3);
#print STDERR "-select, at 2: field names only, extra=$extra=\n";
		#if ($columns =~ /^table_name$/i && $table =~ /^user_tables$/i)  #JWT: FETCH TABLE NAMES! - CHANGED TO NEXT LINE 20010301 TO FIX BUG.
		if ($columns =~ /^table_name\s*$/i && $table =~ /^user_tables$/i)  #JWT: FETCH TABLE NAMES!
		{
			$full_path = $self->{directory};
			$full_path .= $self->{separator}->{ $self->{platform} }  
					unless ($full_path !~ /\S/ 
					|| $full_path =~ m#$self->{separator}->{ $self->{platform} }$#);
			my ($cmd);
			#$cmd = "/bin/ls $full_path*"; #NEXT 8 REPLACED W/NEXT 18 20000414 FOR OS-INDEPENDENCE.
			#$cmd = "dir $full_path*"  if ($self->{platform} eq 'PC');
			#$cmd .= $self->{ext};
			#@l = `$cmd`;
			#for (my $i=0;$i<=$#l;$i++)
			#{
			#	chomp $l[$i];
			#}
			$cmd = $full_path . '*' . $self->{ext};
			#my $code = "while (my \$i = <$cmd>)\n";
			my ($code);
			if ($^O =~ /Win/i)  #NEEDED TO MAKE PERL2EXE'S "-GUI" VERSION WORK!
			{
				@l = glob $cmd;
			}
			else
			{
				@l = ();
				$code = "while (my \$i = <$cmd>)\n";
				$code .= <<'END_CODE';
				{
					chomp ($i);
					push (@l, $i);
				}
END_CODE
				eval $code;
			}
			$self->{use_fields} = 'TABLE_NAME';  #ADDED 20000224 FOR DBI!
			$values_or_error = [];
			for ($i=0;$i<=$#l;$i++)	{
				#chomp($l[$i]);   #NO LONGER NEEDED 20000228
				if ($^O =~ /Win/i)   #COND. ADDED 20010321 TO HANDLE WINDOZE FILENAMES (CAN BE UPPER & OR LOWER)!
				{
					$l[$i] =~ s/${full_path}(.*?)$self->{ext}/$1/i;
					$l[$i] =~ s/$self->{ext}$//i;  #ADDED 20000418 - FORCE THIS!
				}
				else
				{
					$l[$i] =~ s/${full_path}(.*?)$self->{ext}/$1/;
					$l[$i] =~ s/$self->{ext}$//;  #ADDED 20000418 - FORCE THIS!
				}
				push (@$values_or_error,[$l[$i]]);
			}
			unshift (@$values_or_error, ($#l+1));
			return $values_or_error;
		}
#print STDERR "-select: 2a\n";
		$thefid = $table;
		$self->check_for_reload ($table) || return (-501);
		if ($extra =~ s/([\s|\)]+)order\s+by\s*(.*)/$1/i)
		{
			$orderclause = $2;
			@ordercols = split(/,/,$orderclause);
			$descorder = ($ordercols[$#ordercols] =~ s/(\w+\W+)desc(?:end|ending)?$/$1/i);  #MODIFIED 20000721 TO ALLOW "desc|descend|descending"!
			#$orderclause =~ s/,\s+/,/g;
			for $i (0..$#ordercols)
			{
				$ordercols[$i] =~ s/\s//g;
				$ordercols[$i] =~ s/[\(\)]+//g;
			}
		}
#print STDERR "-select, at 2c: extra=$extra=\n";
		if ($extra =~ /^\s+where\s*(.+)$/i)
		{
#print STDERR "-select, at 2d: extra=$1=\n";
		
		    $condition = $self->parse_expression ($1);
		}
		#$self->check_for_reload ($table) || return (-501);
		$columns = join (',', @{ $self->{order} }) if ($columns =~ /\*/);
		$columns =~ s/\s//g;
		$columns =~ tr/a-z/A-Z/;
		$self->check_columns ($columns) || return (-502);
	
		$values_or_error = $self->parse_columns ('select', $columns, 
				$condition, '', \@ordercols, $descorder, 0, $distinct);    #JWT
		return $values_or_error;
    }
    elsif  ($query =~ /^select\s+   #HANDLE 1 OR MORE FUNCTIONS IN SELECT. (20000306)
			(.+)\s+
			from\s+
			(\w+)(.*)$/iox)
    {
		my ($column_stuff, $table, $extra) = ($1, $2, $3);
#print STDERR "-select, at 3: field names only, extra=$extra=\n";
    		my (@fields) = ();
    		my ($fnname, $found_parin, $parincnt);

		#SPLIT UP THE FIELDS BEING REQUESTED.

		$column_stuff =~ s/\s+$//;
		while (1)
		{
			$found_parin = 0;
			$column_stuff =~ s/^\s+//;
			$fnname = '';
			$fnname = $1  if ($column_stuff =~ s/^(\w+)//);
			$column_stuff =~ s/^ +//;
			last  unless ($fnname);
			@column_stuff = split(//,$column_stuff);
			if ($#column_stuff <= 0 ||  $column_stuff[0] eq ',')
			{
				push (@fields, $fnname);
				$column_stuff =~ s/^\,//;
				next;
			}

			#FOR FUNCTIONS W/ARGS, WE MUST FIND THE CLOSING ")"!

			for ($i=0;$i<=length($column_stuff);$i++)
			{
				if ($column_stuff[$i] eq '(')
				{
					++$parincnt;
					$found_parin = 1;
				}
				last  if (!$parincnt && $found_parin);
				--$parincnt  if ($column_stuff[$i] eq ')');
			}
			push (@fields, ($fnname . substr($column_stuff,0,$i)));
			$t = substr($column_stuff,$i);
			$t =~ s/^\s*\,//;
			last unless ($t);
			$column_stuff = $t;
		}
		$thefid = $table;
		$self->check_for_reload ($table) || return (-501);
		my ($column_list) = '('.join ('|', @{ $self->{order} }).')';
		$columns = '';
		my (@strings);

		#DETERMINE WHICH WORDS ARE VALID COLUMN NAMES AND CONVERT THEM INTO 
		#THE VARIABLE FOR LATER EVAL IN PARSE_EXPRESSION!  OTHER WORDS ARE 
		#TREATED AS FUNCTION NAMES AND ARE EVALLED AS THEY ARE.

		for (my $i=0;$i<=$#fields;$i++)
		{
			@strings = ();

			#FIRST, WE MUST PROTECT COLUMN NAMES APPEARING IN LITERAL STRINGS!

			$fields[$i] =~ s|(\'[^\']+\')|
					push (@strings, $1);
					"\x02$#strings\x02"
			|eg;

			#NOW CONVERT THE REMAINING COLUMN NAMES TO "$$_{COLUMN_NAME}"!

			$fields[$i] =~ s/($column_list)/
					my ($column_name) = $1;
					$columns .= $column_name . ',';
					"\$\$\_\{\U$column_name\E\}"/ieg;
			$fields[$i] =~ s/\x02(\d+)\x02/$strings[$1]/g; #UNPROTECT LITERALS!
		}
		chop ($columns);

		#PROCESS ANY WHERE AND ORDER-BY CLAUSES.

		if ($extra =~ s/([\s|\)]+)order\s+by\s*(.*)/$1/i)
		{
			$orderclause = $2;
			@ordercols = split(/,/,$orderclause);
			$descorder = ($ordercols[$#ordercols] =~ s/(\w+\W+)desc$/$1/i);
			#$orderclause =~ s/,\s+/,/g;
			for $i (0..$#ordercols)
			{
				$ordercols[$i] =~ s/\s//g;
				$ordercols[$i] =~ s/[\(\)]+//g;
			}
		}
#print STDERR "-select, at 3b: extra=$extra=\n";
		if ($extra =~ /^\s+where\s*(.+)$/i)
		{
#print STDERR "-select, at 3c: extra=$extra=\n";
		    $condition = $self->parse_expression ($1);
		}
		$columns =~ tr/a-z/A-Z/;
		$self->check_columns ($columns) || return (-502);
		$self->{use_fields} = join (',', @{ $self->{order} }[0..$#fields], );
		$values_or_error = $self->parse_columns ('select', $columns, 
				$condition, '', \@ordercols, $descorder, \@fields, $distinct);    #JWT
		return $values_or_error;
    } 
    else     #INVALID SELECT STATEMENT!
    {
		return (-503);
    }
}

sub update
{
    my ($self, $query) = @_;
    my ($i, $path, $regex, $table, $extra, $condition, $all_columns, 
	$columns, $status);
#print "<BR>query=$query=\n";
	my ($psuedocols) = "CURVAL|NEXTVAL";

    ##++
    ##  Hack to allow parenthesis to be escaped!
    ##--

    $query =~ s/\\([()])/sprintf ("%%\0%d: ", ord ($1))/ge;
    $path  =  $self->{path};
    $regex =  $self->{column};

    if ($query =~ /^update\s+($path)\s+set\s+(.+)$/io) {
	($table, $extra) = ($1, $2);

	#ADDED IF-STMT 20010418 TO CATCH 
			#PARENTHESIZED SET-CLAUSES (ILLEGAL IN ORACLE & CAUSE WIERD PARSING ERRORS!)
	if ($extra =~ /^\(.+\)\s*where/)
	{
		$errdetails = 'parenthesis around SET clause?';
		return (-504);
	}
	$thefid = $table;
	$self->check_for_reload ($table) || return (-501);
	return (-511)  unless (-w $self->{file});   #ADDED 19991207!

	$all_columns = {};
	$columns     = '';

	$extra =~ s/\\\\/\x02/g;         #PROTECT "\\"
	#$extra =~ s/\\\'|\'\'/\x03/g;    #PROTECT '', AND \'. #CHANGED 20000303 TO NEXT 2.
	$extra =~ s/\'\'/\x03\x03/g;    #PROTECT '', AND \'.
	$extra =~ s/\\\'/\x03/g;    #PROTECT '', AND \'.
	#$extra =~ s/\\\"|\"\"/\x04/g;   #REMOVED 20000303.

	#$extra =~ s/^[\s\(]+(.*)$/$1/;  #STRIP OFF SURROUNDING SPACES AND PARINS.
	#$extra =~ s/[\s\)]+$/$1/;
	#$extra =~ s/^[\s\(]+//;  #STRIP OFF SURROUNDING SPACES AND PARINS.
	#$extra =~ s/[\s\)]+$//;
	$extra =~ s/^\s+//;  #STRIP OFF SURROUNDING SPACES.
	$extra =~ s/\s+$//;
	#NOW TEMPORARILY PROTECT COMMAS WITHIN (), IE. FN(ARG1,ARG2).
	$column = $self->{column};
	$extra =~ s/($column\s*\=\s*)\'(.*?)\'(,|$)/
		my ($one,$two,$three) = ($1,$2,$3);
		$two =~ s|\,|\x05|g;
		$two =~ s|\(|\x06|g;
		$two =~ s|\)|\x07|g;
		$one."'".$two."'".$three;
	/eg;

	1 while ($extra =~ s/\(([^\(\)]*)\)/
			my ($args) = $1;
			$args =~ s|\,|\x05|g;
			"\x06$args\x07";
			/eg);
	###$extra =~ s/\'(.*?)\'/my ($j)=$1;  #PROTECT COMMAS IN QUOTES.
	###		$j=~s|,|\x05|g; 
	###	"'$j'"/eg;
	@expns = split(',',$extra);
	for ($i=0;$i<=$#expns;$i++)  #PROTECT "WHERE" IN QUOTED VALUES.
	{
		$expns[$i] =~ s/\x05/,/g;
		$expns[$i] =~ s/\x06/\(/g;
		$expns[$i] =~ s/\x07/\)/g;
		$expns[$i] =~ s/\=\s*'([^']*?)where([^']*?)'/\='$1\x05$2'/gi;
		$expns[$i] =~ s/\'(.*?)\'/my ($j)=$1; 
			$j=~s|where|\x05|g; 
		"'$j'"/eg;
	}
	$extra = $expns[$#expns];    #EXTRACT WHERE-CLAUSE, IF ANY.
#print "<BR>extra=$extra=\n";
	$condition = ($extra =~ s/(.*)where(.+)$/where$1/i) ? $2 : '';
	$condition =~ s/\s+//;
	####$condition =~ s/^\((.*)\)$/$1/g;  #REMOVED 20010313 SO "WHERE ((COND) OP (COND) OP (COND)) WOULD WORK FOR DBIX-RECORDSET. (SELECT APPEARS TO WORK WITHOUT THIS).
	#$expns[$#expns] =~ s/where(.+)$//i;
	$expns[$#expns] =~ s/\s*where(.+)$//i;   #20000108 REP. PREV. LINE 2FIX BUG IF LAST COLUMN CONTAINS SINGLE QUOTES.
	##########$expns[$#expns] =~ s/\s*\)\s*$//i;   #20010416: ADDED TO FIX BUG WHERE LAST ")" BEFORE "WHERE" NOT STRIPPED!
	##########ABOVE NOT A BUG -- MUST NOT USE PARINS AROUND UPDATE CLAUSE, IE. 
	##########"update table set (a = b, c = d) where e = f" is INVALID (IN ORACLE ALSO!!!!!!!!
	$column = $self->{column};
	$condition = $self->parse_expression ($condition);
	$columns = '';   #ADDED 20010228. (THESE CHGS FIXED INCORRECT ORDER BUG FOR "TYPE", "NAME", ETC. LISTS IN UPDATES).
	for ($i=0;$i<=$#expns;$i++)  #EXTRACT FIELD NAMES AND 
	                             #VALUES FROM EACH EXPRESSION.
	{
		$expns[$i] =~ s!\s*($column)\s*=\s*(.+)$!
			my ($var) = $1;
			my ($val) = $2;

			$val = &pscolfn($self,$val)  if ($val =~ "$column\.$psuedocols");
			$var =~ tr/a-z/A-Z/;
			$columns .= $var . ',';   #ADDED 20010228.
			$val =~ s|%\0(\d+): |pack("C",$1)|ge;
			$all_columns->{$var} = $val;
			$all_columns->{$var} =~ s/\x02/\\\\/g;
			#$all_columns->{$var} =~ s/\x03/\'\'/g;
			$all_columns->{$var} =~ s/\x03/\'/g;   #20000108 REPL. PREV. LINE - NO NEED TO DOUBLE QUOTES (WE ESCAPE THEM) - THIS AIN'T ORACLE.
#print "<BR>--- ac($var)=$all_columns->{$var}=\n";
			#$all_columns->{$var} =~ s/\x04/\"\"/g;   #REMOVED 20000303.
		!e;
	}
	#$columns   = join (',', keys %$all_columns);  #NEXT 2 CHGD TO 3RD LINE 20010228.
	#$columns =~ tr/a-z/A-Z/;   #JWT
	chop($columns);   #ADDED 20010228.
	#$condition = ($extra =~ /^\s*where\s+(.+)$/i) ? $1 : '';

	#$self->check_for_reload ($table) || return (-501);
	$self->check_columns ($columns)  || return (-502);
	#### MOVED UP ABOVE FOR-LOOP SO "NEXTVAL" GETS EVALUATED IN RIGHT ORDER!
	####$condition = $self->parse_expression ($condition);
	$status    = $self->parse_columns ('update', $columns, 
 			    		             $condition, 
					             $all_columns);
        foreach my $l (@{$self->{order}})
	 {
	 if(exists($DBD::Sprite::Sprite_global_MAX_VAL{uc($l.'|'.$table)}))
	  {
	   delete($DBD::Sprite::Sprite_global_MAX_VAL{uc($l.'|'.$table)});
	  }				      
	 }					             
	return ($status);
    } else {
		return (-504);
    }
}

sub delete 
{
    my ($self, $query) = @_;
    my ($path, $table, $condition, $status, $wherepart);

    $path = $self->{path};

    if ($query =~ /^delete\s+from\s+($path)(?:\s+where\s+(.+))?$/io) {
	$table     = $1;
	$wherepart = $2;
	$thefid = $table;
	$self->check_for_reload ($table) || return (-501);
	return (-511)  unless (-w $self->{file});   #ADDED 19991207!
	if ($wherepart =~ /\S/)
	{
		$condition = $self->parse_expression ($wherepart);
	}
	else
	{
		$condition = 1;
	}
	#$self->check_for_reload ($table) || return (-501);

	$status = $self->delete_rows ($condition);

 	%DBD::Sprite::Sprite_global_MAX_VAL = ();
	return $status;
    } else {
	return (-505);
    }
}

sub drop
{
    my ($self, $query) = @_;
    my ($path, $table, $condition, $status, $wherepart);

    $path = $self->{path};
    %DBD::Sprite::Sprite_global_MAX_VAL = ();
	$_ = undef;
    if ($query =~ /^drop\s+table\s+($path)\s*$/io)
    {
		$table     = $1;
		$self->check_for_reload ($table) || return (-501);
		return (unlink $self->{file} || -501);
		return 
	}
	return (-501);
}

sub delete_rows
{
    my ($self, $condition) = @_;
    my ($status, $loop);
    local $SIG{'__WARN__'} = sub { $status = -510; $errdetails = "$_[0] at ".__LINE__  };
    local $^W = 0;

    #$status = 1;
    $status = 0;

    #for ($loop=0; $loop < scalar @{ $self->{records} }; $loop++) {
	$loop = 0;
	while (1)
	{
		#last  if ($loop > scalar @{ $self->{records} });
		#last  if (!scalar(@{$self->{records}}) || $loop > scalar @{ $self->{records} });  #JWT: 19991222
		last  if (!scalar(@{$self->{records}}) || $loop >= scalar @{ $self->{records} });  #JWT: 20000609 FIX INFINITE LOOP!

		$_ = $self->{records}->[$loop];
	
		if (eval $condition)
		{
			#$self->{records}->[$loop] = undef;
			splice(@{ $self->{records} }, $loop, 1);
			++$status;  #LET'S COUNT THE # RECORDS DELETED!
		}
		else
		{
			++$loop;
		}
    }

	$self->{dirty} = 1  if ($status > 0);
    return $status;
}

sub create
{
	my ($self, $query) = @_;

	my ($i, @keyfields);
### create table table1 (field1 number, field2 varchar(20), field3 number(5,3))
    local (*FILE, $^W);
	local ($/) = $self->{_record};    #JWT:SUPPORT ANY RECORD-SEPARATOR!

    $^W = 0;
	if ($query =~ /^create\s+table\s+($self->{path})\s*\((.+)\)\s*$/i)
	{
		($table, $extra) = ($1, $2);

	    $query =~ tr/a-z/A-Z/;  #ADDED 20000225;
	    #$extra =~ tr/a-z/A-Z/;  #ADDED 20000225;
		$extra =~ s/^\s*//;
		$extra =~ s/\s*$//;
		$extra =~ s/\((.*?)\)/
				my ($precision) = $1;
				$precision =~ s|\,|\x02|g;   #PROTECT COMMAS IN ().
				"($precision)"/eg;
		$extra =~ s/([\'\"])([^\1]*?)\1/
				my ($quote) = $1;
				my ($str) = $2;
				$str =~ s|\,|\x02|g;   #PROTECT COMMAS IN QUOTES.
				"$quote$str$quote"/eg;

		my (@fieldlist) = split(/,/,$extra);
		my ($fields) = '';
		for ($i=0;$i<=$#fieldlist;$i++)
		{
			$fieldlist[$i] =~ s/^\s+//g;
			$fieldlist[$i] =~ s/\s+$//g;
			if ($fieldlist[$i] =~ s/^PRIMARY\s+KEY\s*\(([^\)]+)\)$//i)
			{
				my $keyfields = $1;
				$keyfields =~ s/\s+//g;
				$keyfields =~ tr/a-z/A-Z/;
				@keyfields = split(/\x02/,$keyfields);
			}
		}
		while (@fieldlist)
		{
			$i = shift(@fieldlist);
			#$i =~ s/^\s*\(\s*//;
			last  unless ($i =~ /\S/);
			$i =~ s/\s+DEFAULT\s+(?:([\'\"])([^\1]*?)\1|([\+\-]?[\d\.]+)|(NULL))$/
				my ($value) = $4 || $3 || $2 || $1;
				$value = ''  if ($4);
				push (@values, $value);
				"=<3>"/ieg;
			$i =~ s/\s+/=/;
			$i =~ tr/a-z/A-Z/;
			$fieldname = $i;
			$fieldname =~ s/=.*//;
			my ($tp,$len,$scale);
			$i =~ s/\w+\=//;
			$i =~ s/\s+//g;
			if ($i =~ /(\w+)(?:\((\d+))?(?:\x02(\d+))?/)
			{
				$tp = $1;
				$len = $2;
				$scale = $3;
			}
			else
			{
				$tp = 'VARCHAR2';
			}
			unless ($len)
			{
				$len = 40;
				$len = 10    if ($tp =~ /NUM|INT|FLOAT|DOUBLE/);
				$len = 5000  if ($tp =~ /LONG|BLOB|MEMO/);
			}
			unless ($scale)
			{
				$scale = $len;
				if ($tp eq 'FLOAT')
				{
					$scale -= 3;
				}
				elsif ($tp =~ /$NUMERICTYPES/)
				{
					$scale = 0;
				}
			}
			my ($value) = '';
			if ($i =~ /\<3\>/)
			{
				$value = shift(@values);
				my ($rawvalue);
				#if ($tp =~ /$NUMERICTYPES/)  #CHGD TO NEXT LINE 20010313.
				if (length($value) > 0 && $tp =~ /$NUMERICTYPES/)
				{
					$rawvalue = sprintf(('%.'.$scale.'f'), 
							$value);
				}
				else
				{
					$rawvalue = $value;
				}
				$value = substr($rawvalue,0,$len);
				unless ($self->{LongTruncOk} || $value eq $rawvalue || 
						($tp eq 'FLOAT'))
				{
					$errdetails = "$fieldname to $len chars";
					return (-519);
				}
				if (($tp eq 'FLOAT') 
						&& (int($value) != int($rawvalue)))
				{
					$errdetails = "$fieldname to $len chars";
					return (-519);
				}
				if ($tp eq 'CHAR')
				{
					$rawvalue = sprintf('%-'.$len.'s',$value);
				}
				else
				{
					$rawvalue = $value;
				}
				if ($tp eq 'CHAR')
				{
					$value = sprintf('%-'.$len.'s',$rawvalue);
				}
				else
				{
					$value = $rawvalue;
				}
			}
			$fields .= $fieldname . '=';
			for ($j=0;$j<=$#keyfields;$j++)
			{
				if ($fieldname eq $keyfields[$j])
				{
					$fields .= '*';
					last;
				}
			}
			$fields .= $tp . '(' . $len;
			$fields .= ',' . $scale  if ($scale && $tp =~ /$NUMERICTYPES/);
			$fields .= ')';
			$fields .= '=' . $value  if (length($value));
			$fields .= $self->{_write};
		}
		$fields =~ s|\x02|\,|g;
		#$fields =~ tr/a-z/A-Z/;
		$new_file = $self->get_path_info ($table);
		my ($new_filename) = $new_file;  #ADDED 20000225;
		$new_file .= $self->{ext}  if ($self->{ext});  #JWT:ADD FILE EXTENSIONS.
		$new_file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
		$errdetails = $new_file;           #ADDED NEXT 2 20000225!
		return -520  if (-e $new_file);
		if (open (FILE, ">$new_file"))
		{
			binmode FILE;   #20000404
			$fields =~ s/$self->{_write}$//;
			print FILE "$fields$/";
			close (FILE);
			$self->check_for_reload ($new_filename) || return (-501);  #ADDED 20000225 HANDLE USER DOING CREATE, THEN COMMIT!
		}
		else
		{
			$errdetails = "$@/$? (file:$new_file)";
			return -511;
		}
	}
	elsif ($query =~ /^create\s+sequence\s+($self->{path})(?:\s+inc(?:rement)?\s+by\s+(\d+))?(?:\s+start\s+with\s+(\d+))?/i)
	{
		my ($seqfid, $incval, $startval) = ($1, $2, $3);

		$incval = 0  unless ($incval);
		$startval = 1  unless ($startval);

		my ($new_file) = $self->get_path_info($seqfid) . '.seq';
		$new_file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
		if (open (FILE, ">$new_file"))
		{
			print FILE "$incval,$startval\n";
			close (FILE);
		}
		else
		{
			$errdetails = "$@/$? (file:$new_file)";
			return -511;
		}
	}
}

sub alter
{
    my ($self, $query) = @_;
    my ($i, $path, $regex, $table, $extra, $type, $column, $count, $status);
    my ($posn);
    %DBD::Sprite::Sprite_global_MAX_VAL = ();
    $path  = $self->{path};
    $regex = $self->{column};

	if ($query =~ /^alter\s+table\s+($path)\s+(.+)$/io)
	{
		($table, $extra) = ($1, $2);
		if ($extra =~ /^(add|modify|drop)\s*(.+)$/io)
		{
			($type, $columnstuff) = ($1, $2);
			$columnstuff =~ s/^\s*\(//;
			$columnstuff =~ s/\)\s*$//;
###alter table table2 add (newcol1  varchar(5), newcol2 varchar(10))
			$columnstuff =~ s/\((.*?)\)/
				my ($precision) = $1;
				$precision =~ s|\,|\x02|g;   #PROTECT COMMAS IN ().
				"($precision)"/eg;
			$columnstuff =~ s/([\'\"])([^\1]*?)\1/
				my ($quote) = $1;
				my ($str) = $2;
				$str =~ s|\,|\x02|g;   #PROTECT COMMAS IN QUOTES.
				"$quote$str$quote"/eg;

			$thefid = $table;
			$self->check_for_reload ($table) || return (-501);
			my (@values) = ();
			my (@fieldlist) = split(/,/,$columnstuff);
			my ($olddf, $oldln);
			while (@fieldlist)
			{
				$i = shift(@fieldlist);
				$i =~ s/^\s+//g;
				$i =~ s/\s+$//g;
				last  unless ($i =~ /\S/);
				$i =~ s/\x02/\,/g;
				$i =~ s/\s+DEFAULT\s+(?:([\'\"])([^\1]*?)\1|([\+\-]?[\d\.]+)|(NULL))$/
					my ($value) = $4 || $3 || $2 || $1;
					$value = "\x04"  if ($4);
					push (@values, $value);
					"=\x03"/ieg;
				$posn = undef;
				$posn = $1  if ($i =~ s/^(\d+)\s*//);
				$i =~ s/\s+/=/;
				$fd = $i;
				$fd =~ s/=.*//;
				$fd =~ tr/a-z/A-Z/;
				for ($j=0;$j<=$#keyfields;$j++)
				{
					$i =~ s/=/=*/  if ($fd eq $keyfields[$j]);
				}
				$x = undef;
				$tp = undef;
				$i =~ /\w+\=[\*]?(\w*)\s*(.*)/;
				($tp, $x) = ($1, $2);
				$oldln = 0;
				$tp =~ tr/a-z/A-Z/;
				if ($type =~ /modify/i)
				{
					unless ($tp =~ /[a-zA-Z]/)
					{
						$tp = $self->{types}->{$fd};
					}
					unless ($tp eq $self->{types}->{$fd})
					{
						if ($#{$self->{records}} >= 0)
						{
							$errdetails = ($#{$self->{records}}+1) . ' records!';
							return -521;
						}
					}
					$olddf = undef;
					$olddf = $self->{defaults}->{$fd}  if (defined $self->{defaults}->{$fd});
					unless ($tp eq $self->{types}->{$fd})
					{
						$self->{lengths}->{$fd} = 0;
						$self->{scales}->{$fd} = 0;
					}
					$oldln = $self->{lengths}->{$fd};
				}
				$self->{defaults}->{$fd} = undef;
				$self->{lengths}->{$fd} = $1  if ($x =~ s/(\d+)//);
				unless ($self->{lengths}->{$fd})
				{
					$self->{lengths}->{$fd} = 40;
					$self->{lengths}->{$fd} = 10  if ($tp =~ /NUM|INT|FLOAT|DOUBLE/);
					$self->{lengths}->{$fd} = 5000  if ($tp =~ /LONG|BLOB|MEMO/);
				}
				if ($self->{lengths}->{$fd} < $oldln)
				{
					$errdetails = $fd;
					return -522;
				}
				$x =~ s/\x03/
						$self->{defaults}->{$fd} = shift(@values);
						#$self->{defaults}->{$fd} =~ s|\x02|\,|g;
						$self->{defaults}->{$fd}/eg;
				$self->{fields}->{$fd} = 1;
				$self->{types}->{$fd} = $tp;
				$self->{defaults}->{$fd} = $olddf  
					if ((defined $olddf) && !(defined $self->{defaults}->{$fd}));
				$self->{defaults}->{$fd} = undef  if ($self->{defaults}->{$fd} eq "\x04");
				if ($x =~ s/\,\s*(\d+)//)
				{
					$self->{scales}->{$fd} = $1;
				}
				elsif ($self->{types}->{$fd} eq 'FLOAT')
				{
					$self->{scales}->{$fd} = $self->{lengths}->{$fd} - 3;
				}
				if (defined $self->{defaults}->{$fd})
				{
					my ($val);
					#if (${$self->{types}}{$fd} =~ /$NUMERICTYPES/)  #CHGD TO NEXT LINE 20010313.
					if (length($self->{defaults}->{$fd}) > 0 && ${$self->{types}}{$fd} =~ /$NUMERICTYPES/)
					{
						$val = sprintf(('%.'.${$self->{scales}}{$fd}.'f'),
								$self->{defaults}->{$fd});
					}
					else
					{
						$val = $self->{defaults}->{$fd};
					}
					$self->{defaults}->{$fd} = substr($val,0,
							${$self->{lengths}}{$fd});
					unless ($self->{LongTruncOk} 
							|| $self->{defaults}->{$fd} eq $val
							|| ${$self->{types}}{$fd} eq 'FLOAT')
					{
						$errdetails = "$fd to ${$self->{lengths}}{$fd} chars";
						return (-519);
					}
					if (${$self->{types}}{$fd} eq 'FLOAT' && 
							int($self->{defaults}->{$fd}) != int($val))
					{
						$errdetails = "$fd to ${$self->{lengths}}{$fd} chars";
						return (-519);
					}
					if (${$self->{types}}{$fd} eq 'CHAR')
					{
						$val = sprintf('%-'.${$self->{lengths}}{$fd}.'s', 
								$self->{defaults}->{$fd});
						$self->{defaults}->{$fd} = $val;
					}

					#THIS CODE SETS ALL EMPTY VALUES FOR THIS FIELD TO THE 
					#DEFAULT VALUE.  ORACLE DOES NOT DO THIS!
					#for ($j=0;$j < scalar @{ $self->{records} }; $j++)
					#{
					#	$self->{records}->[$j]->{$fd} = $self->{defaults}->{$fd}  
					#			unless (length($self->{records}->[$j]->{$fd}));
					#}
				}
				if ($type =~ /add/i)
				{
					if (defined $posn)
					{
						my (@myorder) = (@{ $self->{order} }[0..($posn-1)], 
							$fd, 
							@{ $self->{order} }[$posn..$#{ $self->{order} }]);
						@{ $self->{order} } = @myorder;
					}
					else
					{
						push (@{ $self->{order} }, $fd);
					}
				}
				elsif ($type =~ /modify/i)
				{
					if (defined $posn)
					{
						for ($j=0;$j<=$#{ $self->{order} };$j++)
						{
							if (${ $self->{order} }[$j] eq $fd)
							{
								splice (@{ $self->{order} }, $j, 1);
								my (@myorder) = (@{ $self->{order} }[0..($posn-1)], 
									$fd, 
									@{ $self->{order} }[$posn..$#{ $self->{order} }]);
								@{ $self->{order} } = @myorder;
								last;
							}
						}
					}
				}
				elsif ($type =~ /drop/i)
				{
					$self->check_columns ($fd) || return (-502);
					$count = -1;
					foreach (@{ $self->{order} })
					{
						++$count;
						last if ($_ eq $fd);
					}
					splice (@{ $self->{order} }, $count, 1);
					delete $self->{fields}->{$fd};
					delete $self->{types}->{$fd};
					delete $self->{lengths}->{$fd};
					delete $self->{scales}->{$fd};
				}
			}

			$status = $self->parse_columns ("\L$type\E", $column);
			$self->{dirty} = 1;
			$self->commit($table);
			return $status;
		}
		else
		{
	 	   return (-506);
		}
	}
	else
	{
		return (-507);
	}
}

sub insert
{
    my ($self, $query) = @_;
    my ($i, $path, $table, $columns, $values, $status);
#print "-INSERT: query=$query=\n";
    $path = $self->{path};
    if ($query =~ /^insert\s+into\s+                            # Keyword
                   ($path)\s*                                  # Table
                   (?:\((.+?)\)\s*)?                               # Keys
                   values\s*                                    # 'values'
                   \((.+)\)$/ixo)
{   #JWT: MAKE COLUMN LIST OPTIONAL!

	($table, $columns, $values) = ($1, $2, $3);
	$thefid = $table;
	$self->check_for_reload ($table) || return (-501);
	$columns =~ s/\s//g;
	$columns = join(',', @{ $self->{order} })  unless ($columns =~ /\S/);  #JWT
	#$self->check_for_reload ($table) || return (-501);
	return (-511)  unless (-w $self->{file});
$fieldregex = $self->{fieldregex};
	unless ($columns =~ /\S/)
	{
		local (*FILE);
		local ($/) = $self->{_record};    #JWT:SUPPORT ANY RECORD-SEPARATOR!
		#??? $self->{file} =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});     #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
		$thefid = $self->{file};
		open(FILE, $self->{file}) || return (-501);
		binmode FILE;   #20000404
		$columns = <FILE>;
		#chop ($columns);
		chomp ($columns);  #20000927
		$columns =~ s/$self->{_read}/,/g;
		@{$self->{order}} = split(/,/, $columns);
		close FILE;
	}

	$values =~ s/\\\\/\x02/g;         #PROTECT "\\"
	#$values =~ s/\\\'|\'\'/\x03/g;    #PROTECT '', AND \'. #CHANGED 20000303 TO NEXT 2.
	$values =~ s/\'\'/\x03\x03/g;    #PROTECT '', AND \'.
	$values =~ s/\\\'/\x03/g;    #PROTECT '', AND \'.
	
	$values =~ s/\'(.*?)\'/
			my ($j)=$1; 
			$j=~s|,|\x04|g;         #PROTECT "," IN QUOTES.
			"'$j'"
	/eg;
		
	@values = split(/,/,$values);
	$values = '';
	for $i (0..$#values)
	{
		$values[$i] =~ s/^\s+//;      #STRIP LEADING & TRAILING SPACES.
		$values[$i] =~ s/\s+$//;
		$values[$i] =~ s/\x03/\'/g;   #RESTORE PROTECTED SINGLE QUOTES HERE.
		$values[$i] =~ s/\x02/\\/g;   #RESTORE PROTECTED SLATS HERE.
		$values[$i] =~ s/\x04/,/g;    #RESTORE PROTECTED COMMAS HERE.
		if ($values[$i] =~ /^[_a-zA-Z]/)
		{
			if ($values[$i] =~ /\s*(\w+).NEXTVAL\s*$/ 
					|| $values[$i] =~ /\s*(\w+).CURVAL\s*$/)
			{
				my ($seq_file) = $self->get_path_info($1) . '.seq';
				#### REMOVED 20010814 - ALREAD DONE IN GET_PATH_INFO!!!! ####$seq_file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
				#open (FILE, "<$seq_file") || return (-511);
				unless (open (FILE, "<$seq_file"))
				{
					$errdetails = "$@/$? (file:$seq_file)";
					return (-511);
				}
				$x = <FILE>;
				#chomp($x);
				$x =~ s/\s+$//;   #20000113  CHOMP WON'T WORK HERE IF RECORD DELIMITER SET TO OTHER THAN \n!
				($incval, $startval) = split(/,/,$x);
				close (FILE);
				$_ = $values[$i];
				if (/\s*(\w+).NEXTVAL\s*$/)
				{
					#open (FILE, ">$seq_file") || return (-511);
					unless (open (FILE, ">$seq_file"))
					{
						$errdetails = "$@/$? (file:$seq_file)";
						return (-511);
					}
					$incval += ($startval || 1);
					print FILE "$incval,$startval\n";
					close (FILE);
				}
				$values[$i] = $incval;
			}
			else
			{
				#eval {$values[$i] = &{$values[$i]} };
				$values[$i] = eval &chkcolumnparms($values[$i]);   #FUNCTION EVAL 2
				return (-517)  if ($@);
			}
		}
	};
	chop($values);
	$self->check_columns ($columns)  || return (-502);

	$status = $self->insert_data ($columns, @values);

#	foreach my $l (@{$self->{order}})
#	 {
#	 if(exists($DBD::Sprite::Sprite_global_MAX_VAL{uc($l.'|'.$table)}))
#	  {
#	   delete($DBD::Sprite::Sprite_global_MAX_VAL{uc($l.'|'.$table)});
#	  }				      
#	 }
	return $status;
	} else {
		return (-508);
	}
}

sub insert_data
{
    my ($self, $column_string, @values) = @_;
    my (@columns, $hash, $loop, $column, $j, $k);
	$column_string =~ tr/a-z/A-Z/;
    @columns = split (/,/, $column_string);
    #JWT: @values  = $self->quotewords (',', 0, $value_string);

    if ($#columns == $#values) {
    
	my (@keyfields) = split(',', $self->{key_fields});  #JWT: PREVENT DUP. KEYS.
	my ($matchcnt) = 0;
	
	$hash = {};

    foreach $column (@{ $self->{order} })
    {
		$column =~ tr/a-z/A-Z/;   #JWT
		$hash->{$column} = $self->{defaults}->{$column}  
				if (length($self->{defaults}->{$column}));
    }

	for ($loop=0; $loop <= $#columns; $loop++)
	{
	    $column = $columns[$loop];
		$column =~ tr/a-z/A-Z/;   #JWT
	
		my ($v);
		if ($self->{fields}->{$column})
		{
			$values[$loop] =~ s/^\'(.*)\'$/my ($stuff) = $1; 
			#$stuff =~ s|\'|\\\'|g;
			$stuff =~ s|\'\'|\'|g;
			$stuff/e;
			$values[$loop] =~ s|^\'$||;      #HANDLE NULL VALUES!!!.
			if (length($values[$loop]) || !length($self->{defaults}->{$column}))
			{
				$v = $values[$loop];
			}
			else
			{
				$v = $self->{defaults}->{$column};
			}
			#if (${$self->{types}}{$column} =~ /$NUMERICTYPES/)  #CHGD TO NEXT LINE 20010313.
			if (length($v) > 0 && ${$self->{types}}{$column} =~ /$NUMERICTYPES/)
			{
				$hash->{$column} = sprintf(('%.'.${$self->{scales}}{$column}.'f'), $v);
			}
			else
			{
				$hash->{$column} = $v;
			}
			$v = substr($hash->{$column},0,${$self->{lengths}}{$column});
			unless ($self->{LongTruncOk} || $v eq $hash->{$column} || 
					(${$self->{types}}{$column} eq 'FLOAT'))
			{
				$errdetails = "$column to ${$self->{lengths}}{$column} chars";
				return (-519);
			}
			if ((${$self->{types}}{$column} eq 'FLOAT') 
					&& (int($v) != int($hash->{$column})))
			{
				$errdetails = "$column to ${$self->{lengths}}{$column} chars";
				return (-519);
			}
			elsif (${$self->{types}}{$column} eq 'CHAR')   #ADDED 20000327!
			{
				$hash->{$column} = sprintf('%-'.${$self->{lengths}}{$column}.'s',$v);
			}
			else
			{
				$hash->{$column} = $v;
			}
		}
	}

	#20000201 - FIX UNIQUE-KEY TEST FOR LARGE DATASETS.
	
recloop: 	for ($k=0;$k < scalar @{ $self->{records} }; $k++)  #CHECK EACH RECORD.
	{
		$matchcnt = 0;
valueloop:		foreach $column (keys %$hash)   #CHECK EACH NEW VALUE AGAINST IT'S RESPECTIVE COLUMN.
		{
keyloop:			for ($j=0;$j<=$#keyfields;$j++)  
			{
				if ($column eq $keyfields[$j])
				{
					if ($self->{records}->[$k]->{$column} eq $hash->{$column})
					{
						++$matchcnt;
						return (-518)  if ($matchcnt && $matchcnt > $#keyfields);  #ALL KEY FIELDS WERE DUPLICATES!
					}
				}
			}
		}
		#return (-518)  if ($matchcnt && $matchcnt > $#keyfields);  #ALL KEY FIELDS WERE DUPLICATES!
	}


	push @{ $self->{records} }, $hash;
	
	$self->{dirty} = 1;
	
	return (1);
    } else {
		$errdetails = "$#columns != $#values";   #20000114
		return (-509);
    }
}						    

sub write_file
{
    my ($self, $new_file) = @_;
    my ($i, $j, $status, $loop, $record, $column, $value, $fields, $record_string);
	my (@keyfields) = split(',', $self->{key_fields});  #JWT: PREVENT DUP. KEYS.

    local (*FILE, $^W);
	local ($/) = $self->{_record};    #JWT:SUPPORT ANY RECORD-SEPARATOR!

    $^W = 0;

    #$status = (scalar @{ $self->{records} }) ? 1 : -513;
    $status = 1;   #JWT 19991222

	return 1  if $#{$self->{order}} < 0;  #ADDED 20000225 PREVENT BLANKING OUT TABLES, IE IF USER CREATES SEQUENCE W/SAME NAME AS TABLE, THEN COMMITS!
	
		#########$new_file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
    if ( ($status >= 1) && (open (FILE, ">$new_file")) ) {
	binmode FILE;   #20000404

	if (($^O eq 'MSWin32') or ($^O =~ /cygwin/i))
	{
		$self->lock || $self->display_error (-515);
	}
	else    #GOOD, MUST BE A NON-M$ SYSTEM :-)
	{
		eval { flock (FILE, $JSprite::LOCK_EX) || die };

		if ($@)
		{
			$self->lock || $self->display_error (-515)  if ($@);
		}
	}
	
	#$fields = join ($self->{_write}, @{ $self->{order} });
	$fields = '';
	for $i (0..$#{$self->{order}})
	{
		$fields .= ${$self->{order}}[$i] . '=';
		for ($j=0;$j<=$#keyfields;$j++)  #JWT: MARK KEY FIELDS.
		{
			$fields .= '*'  if (${$self->{order}}[$i] eq $keyfields[$j])
		}
		$fields .= ${$self->{types}}{${$self->{order}}[$i]} . '(' 
				. ${$self->{lengths}}{${$self->{order}}[$i]};
		if (${$self->{scales}}{${$self->{order}}[$i]} 
				&& ${$self->{types}}{${$self->{order}}[$i]} =~ /$NUMERICTYPES/)
		{
			$fields .= ',' . ${$self->{scales}}{${$self->{order}}[$i]}
		}
		#$fields .= ')' . $self->{_write};
		$fields .= ')';
		$fields .= '='. ${$self->{defaults}}{${$self->{order}}[$i]}  
				if (length(${$self->{defaults}}{${$self->{order}}[$i]}));
		$fields .= $self->{_write};
	}
	$fields =~ s/$self->{_write}$//;

	#$fields =~ tr/a-z/A-Z/;   #JWT:MAKE SURE COLUMNS are UPPERCASE!
	print FILE "$fields$/";

	for ($loop=0; $loop < scalar @{ $self->{records} }; $loop++) {
	    $record = $self->{records}->[$loop];

	    next unless (defined $record);

         $record_string = '';

 	    foreach $column (@{ $self->{order} })
 	    {
			if (${$self->{types}}{$column} eq 'CHAR') #20000224
			{
				$value = sprintf(
						'%-'.${$self->{lengths}}{$column}.'s',
						$record->{$column});
			}
			#elsif (${$self->{types}}{$column} =~ /$NUMERICTYPES/)
			#{
			#	$value = sprintf(('%.'.${$self->{scales}}{$column}.'f'), 
			#			$record->{$column});
			#}
			else
			{
				$value = $record->{$column};
			}

			$record_string .= "$self->{_write}$value";
	    }

	    $record_string =~ s/^$self->{_write}//o;

	    print FILE "$record_string$/";
	}

	close (FILE);

	my (@stats) = stat ($new_file);
	$self->{timestamp} = $stats[9];

        $self->unlock || $self->display_error (-516);
    } else {
		$status = ($status < 1) ? $status : -511;
    }
    return $status;
}

sub load_database 
{
    my ($self, $file) = @_;
    my ($i, $header, @fields, $no_fields, @record, $hash, $loop, $tp, $dflt);

    local (*FILE);
	local ($/) = $self->{_record};    #JWT:SUPPORT ANY RECORD-SEPARATOR!

	########$file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
	$thefid = $file;
    open (FILE, $file) || return (-501);
	binmode FILE;   #20000404

	if (($^O eq 'MSWin32') or ($^O =~ /cygwin/i))
	{
		$self->lock || $self->display_error (-515);
	}
	else    #GOOD, MUST BE A NON-M$ SYSTEM :-)
	{
		eval { flock (FILE, $JSprite::LOCK_EX) || die };

		if ($@)
		{
			$self->lock || $self->display_error (-515)  if ($@);
		}
	}

    $_ = <FILE>;
	chomp;          #JWT:SUPPORT ANY RECORD-SEPARATOR!

    ($header)  = /^ *(.*?) *$/;
	#####################$header =~ tr/a-z/A-Z/;   #JWT  20000316
    @fields    = split (/$self->{_read}/o, $header);
    $no_fields = $#fields;

	undef %{ $self->{types} };
	undef %{ $self->{lengths} };
	undef %{ $self->{scales} };   #ADDED 20000306.
	$self->{use_fields} = '';
	$self->{key_fields} = '';   #20000223 - FIX LOSS OF KEY ASTERISK ON ROLLBACK!
	foreach $i (0..$#fields)
	{
		$dflt = undef;
		($fields[$i],$tp,$dflt) = split(/=/,$fields[$i]);
		$fields[$i] =~ tr/a-z/A-Z/;
		$tp = 'VARCHAR(40)'  unless($tp);
		$tp =~ tr/a-z/A-Z/;
		$self->{key_fields} .= $fields[$i] . ',' 
				if ($tp =~ s/^\*//);   #JWT:  *TYPE means KEY FIELD!
		$ln = 40;
		$ln = 10  if ($tp =~ /NUM|INT|FLOAT|DOUBLE/);
		$ln = 5000  if ($tp =~ /LONG|BLOB|MEMO/);
		$ln = $2  if ($tp =~ s/(.*)\((.*)\)/$1/);
		${$self->{types}}{$fields[$i]} = $tp;
		${$self->{lengths}}{$fields[$i]} = $ln;
		${$self->{defaults}}{$fields[$i]} = undef;
		${$self->{defaults}}{$fields[$i]} = $dflt  if (defined $dflt);
		if (${$self->{lengths}}{$fields[$i]} =~ s/\,(\d+)//)
		{
			#NOTE:  ORACLE NEGATIVE SCALES NOT CURRENTLY SUPPORTED!
			
			${$self->{scales}}{$fields[$i]} = $1;
		}
		elsif (${$self->{types}}{$fields[$i]} eq 'FLOAT')
		{
			${$self->{scales}}{$fields[$i]} = ${$self->{lengths}}{$fields[$i]} - 3;
		}
		${$self->{scales}}{$fields[$i]} = '0'  unless (${$self->{scales}}{$fields[$i]});
	
		# (JWT 8/8/1998) $self->{use_fields} .= $column_string . ',';    #JWT
		$self->{use_fields} .= $fields[$i] . ',';    #JWT
	}
	chop ($self->{use_fields})  if ($self->{use_fields});  #REMOVE TRAILING ','.
	chop ($self->{key_fields})  if ($self->{key_fields});

    undef %{ $self->{fields} };
    undef @{ $self->{order}  };

    $self->{order} = [ @fields ];
	$self->{fieldregex} = $self->{use_fields};
	$self->{fieldregex} =~ s/,/\|/g;

    map    { $self->{fields}->{$_} = 1 } @fields;
    undef @{ $self->{records} } if (scalar @{ $self->{records} });

    while (<FILE>) {
	chomp;
	#chop;     #JWT:SUPPORT ANY RECORD-SEPARATOR!
	next unless ($_);
	#s/""/\\"/g;   #REMOVED 20000303.

	#if (/['"\\]/) {
    #        @record = $self->quotewords ($self->{_read}, 0, $_);
    #    } else {
            @record = split (/$self->{_read}/o, $_);
    #    }

	$hash = {};

	for ($loop=0; $loop <= $no_fields; $loop++) {
	    $hash->{ $fields[$loop] } = $record[$loop];
	}

	push @{ $self->{records} }, $hash;
    }
	
    close (FILE);

    $self->unlock || $self->display_error (-516);

    return (1);
}

sub pscolfn
{
	my ($self,$id) = @_;
	return $id  unless ($id =~ /CURVAL|NEXTVAL/);
	my ($value) = '';
	my ($seq_file,$col) = split(/\./,$id);
	$seq_file = $self->get_path_info($seq_file) . '.seq';

	$seq_file =~ tr/A-Z/a-z/  unless ($self->{CaseTableNames});  #JWT:TABLE-NAMES ARE NOW CASE-INSENSITIVE!
	#open (FILE, "<$seq_file") || return (-511);
	unless (open (FILE, "<$seq_file"))
	{
		$errdetails = "$@/$? (file:$seq_file)";
		return (-511);
	}
	$x = <FILE>;
	#chomp($x);
	$x =~ s/\s+$//;   #20000113
	($incval, $startval) = split(/,/,$x);
	close (FILE);
	if ($id =~ /NEXTVAL/)
	{
		#open (FILE, ">$seq_file") || return (-511);
		unless (open (FILE, ">$seq_file"))
		{
			$errdetails = "$@/$? (file:$seq_file)";
			return (-511);
		}
		$incval += ($startval || 1);
		print FILE "$incval,$startval\n";
		close (FILE);
	}
	$value = $incval;
	return $value;
}

##++
##  NOTE: Derived from lib/Text/ParseWords.pm. Thanks Hal!
##--

sub quotewords {   #SPLIT UP USER'S SEARCH-EXPRESSION INTO "WORDS" (TOKENISE)!

# THIS CODE WAS COPIED FROM THE PERL "TEXT" MODULE, (ParseWords.pm),
# written by:  Hal Pomeranz (pomeranz@netcom.com), 23 March 1994
# (Thanks, Hal!)
# MODIFIED BY JIM TURNER (6/97) TO ALLOW ESCAPED (REGULAR-EXPRESSION)
# CHARACTERS TO BE INCLUDED IN WORDS AND TO COMPRESS MULTIPLE OCCURRANCES
# OF THE DELIMITER CHARACTER TO BE COMPRESSED INTO A SINGLE DELIMITER
# (NO EMPTY WORDS).
#
# The inner "for" loop builds up each word (or $field) one $snippet
# at a time.  A $snippet is a quoted string, a backslashed character,
# or an unquoted string.  We fall out of the "for" loop when we reach
# the end of $_ or when we hit a delimiter.  Falling out of the "for"
# loop, we push the $field we've been building up onto the list of
# @words we'll be returning, and then loop back and pull another word
# off of $_.
#
# The first two cases inside the "for" loop deal with quoted strings.
# The first case matches a double quoted string, removes it from $_,
# and assigns the double quoted string to $snippet in the body of the
# conditional.  The second case handles single quoted strings.  In
# the third case we've found a quote at the current beginning of $_,
# but it didn't match the quoted string regexps in the first two cases,
# so it must be an unbalanced quote and we croak with an error (which can
# be caught by eval()).
#
# The next case handles backslashed characters, and the next case is the
# exit case on reaching the end of the string or finding a delimiter.
#
# Otherwise, we've found an unquoted thing and we pull of characters one
# at a time until we reach something that could start another $snippet--
# a quote of some sort, a backslash, or the delimiter.  This one character
# at a time behavior was necessary if the delimiter was going to be a
# regexp (love to hear it if you can figure out a better way).

	my ($self, $delim, $keep, @lines) = @_;
	my (@words,$snippet,$field,$q,@quotes);

	$_ = join('', @lines);
	while ($_) {
		$field = '';
		for (;;) {
			$snippet = '';
			@quotes = ('\'','"');
			if (s/^(["'`])(.+?)\1//) {
				$snippet = $2;
				$snippet = "$1$snippet$1" if ($keep);
$field .= $snippet;
last;
			}	
			elsif (/^["']/) {
				#print "Error:  Unmatched quote near ($_)!<BR>\n";
				$self->display_error(-512);
				return ();
			}
			elsif (s/^\\(.)//) {
				$snippet = $1;
				$snippet = "\\$snippet" if ($keep);
			}
			elsif (!$_ || s/^$delim//) {  #REMOVE "+" TO REMOVE DELIMITER-COMPRESSION.
				last;
			}
			else {
				while ($_ && !(/^$delim/)) {  #ATTEMPT TO HANDLE TWO QUOTES IN A ROW.
					last  if (/^['"]/ && ($snippet !~ /\\$/));
					$snippet .= substr($_, 0, 1);
					substr($_, 0, 1) = '';
				}
			}
			$field .= $snippet;
		}
	push(@words, $field);
	}
	@words;
}

sub chkcolumnparms   #ADDED 20001218 TO CHECK FUNCTION PARAMETERS FOR FIELD-NAMES.
{
	my ($evalstr) = shift;
	$evalstr =~ s/\\\'|\'\'/\x02/g;   #PROTECT QUOTES W/N QUOTES.
	$evalstr =~ s/\\\"|\"\"/\x03/g;   #PROTECT QUOTES W/N QUOTES.
	
	$i = -1;
	my (@strings);     #PROTECT ANYTHING BETWEEN QUOTES (FIELD NAMES IN LITERALS).
	$evalstr =~ s/([\'\"])([^\1]*?)\1/
			++$i;
			$strings[$i] = "$1$2$1";
			"\x04$i";
	/eg;

	#FIND EACH FIELD NAME PARAMETER & REPLACE IT WITH IT'S VALUE || NAME || EMPTY-STRING.

	$evalstr =~ s/($fieldregex)/
				$res = (defined $_->{$1}) ? $_->{$1} : $1;
				$res ||= '""';
				$res;
	/eg;

	$evalstr =~ s/\x04(\d+)/$strings[$1]/g;   #UNPROTECT LITERALS
	$evalstr =~ s/\x03/\\\'/g;                #UNPROTECT QUOTES.
	$evalstr =~ s/\x02/\\\"/g;
	return $evalstr;
}

sub SYSTIME
{
	return time;
}

sub NUM
{
	return shift;
}

sub NULL
{
	return '';
}

sub ROWNUM
{
	return (scalar (@$results) + 1);
}

sub fn_register   #REGISTER SQL-CALLABLE FUNCTIONS.
{
	shift  if (ref($_[0]) eq 'HASH');   #20000224
	my ($fnname, $packagename) = @_;
	$packagename = 'main'  unless ($packagename);

	eval <<END_EVAL;
		sub $fnname
		{
			return &${packagename}::$fnname;
		}
END_EVAL
}

1;
