sub SUBSTR
{
	#@_ = &chkcolumnparms(@_);
	my ($s) = shift;
	my ($p) = shift;
	#($s, $p) = &chkcolumnparms(@_);

	return ''  unless ($p);

	--$p  if ($p > 0);

	my ($l) = shift;
	return (substr($s, $p))  unless ($l);
	return substr($s, $p, $l);
}

sub LOWER
{
	#@_ = &chkcolumnparms(@_);
	my ($s) = shift;
	$s =~ tr/A-Z/a-z/;
	return $s;
}

sub UPPER
{
	#@_ = &chkcolumnparms(@_);
	my ($s) = shift;
	$s =~ tr/a-z/A-Z/;
	return $s;
}

sub TO_DATE
{
	#@_ = &chkcolumnparms(@_);
	do 'to_date.pl';
	if ($err =~ /^Invalid/)
	{
		$errdetails = $err;
		$rtnTime = '';
		$self->display_error(-503);
	}
	return $rtnTime;
}

sub CONCAT
{

	#@_ = &chkcolumnparms(@_);
	return $_[0].$_[1];
}

sub MAXVAL
{
	my ($in) = @_;
	my ($col,$tabl) = split(/\|/,$in);
	my $maximum = -1;
	if(exists($DBD::Sprite::Sprite_global_MAX_VAL{uc($in)}))
	  {
	   $DBD::Sprite::Sprite_global_MAX_VAL{uc($in)}++;
	   return($DBD::Sprite::Sprite_global_MAX_VAL{uc($in)});
	  }
	my $dbh = $DBD::Sprite::Sprite_global_db_handler;
	$res = $dbh->prepare("select $col from $tabl");
	if($res)
	 {
       	  $res->execute();
	  my $val;
	  while(($val = $res->fetchrow_arrayref()))
 	   {
	    my ($slf) = @$val;
  	    if($slf > $maximum) {$maximum = $slf;}
	   }
	  $maximum++;
	 }
	else {$maximum = -1;}
	$DBD::Sprite::Sprite_global_MAX_VAL{uc($in)} = $maximum;
	return $maximum;
}
sub NOW
{
 return(scalar(time()));
}

1;
