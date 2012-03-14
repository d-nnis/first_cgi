#!f:/Perl64/bin/perl -w

use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);

##
use WWW::Mechanize;
use HTTP::Cookies;
use feature qw/switch/;
use HTML::PullParser;
use HTML::TokeParser;
use base qw(HTML::Parser);
##

my $perl_version = $];
#my $module_version = ${$WWW::VERSION};

read(STDIN, my $Daten, $ENV{'CONTENT_LENGTH'});
my @Formularfelder = split(/&/, $Daten);
# Daten
# username=Dennis&pwd=pasworth&Kommentartext=
my ($Feld, $Name, $Wert);
my %Formular;
foreach $Feld (@Formularfelder) {
  (my $Name, my $Wert) = split(/=/, $Feld);
  $Wert =~ tr/+/ /;
  $Wert =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $Wert =~ s/</&lt;/g;
  $Wert =~ s/>/&gt;/g;
  $Formular{$Name} = $Wert;
}

my $browser = WWW::Mechanize->new();
my $tp = HTML::TokeParser->new(doc => \$browser->content);
my $url = "http://web6.codeprobe.de/wikka/TestLogin";
my $cookie_file = "f:\\Users\\d-nnis\\cookie_cgi_comments.txt";

sub login {
	my $cookie_jar = HTTP::Cookies->new(file => "$cookie_file", autosave => 1);
	$browser->cookie_jar($cookie_jar);
	my @fields;
	push @fields, "name";
	push @fields, "password";
	$browser->get("http://web6.codeprobe.de/wikka/UserSettings");
	#$browser->form_id("form_42b90196b4");
	## form_id noch nicht in Version 1.32
	## -> Perl64-Installation verwenden!
	$browser->form_with_fields(@fields);

	print "username:", $Formular{'username'},"-\n";
	print "pwd:", $Formular{'pwd'},"-\n";
	$browser->field(name=>$Formular{'username'});
	$browser->field(password=>$Formular{'pwd'});
	getstate($browser->content);
	$browser->click();
}

login();


$browser->get($url);
$tp = HTML::TokeParser->new(doc => \$browser->content);
my $text;
#while (my $token = $tp->get_tag('a')) {
while (my $token = $tp->get_tag('title')) {
	#next unless $token->[1]{class} eq 'keys';
	$text = $tp->get_trimmed_text('title');
	#$text = $token->[1]{href};
	
}

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">', "\n";
print "<html><head><title>CGI-Feedback</title></head>\n";
print "<body><h1>CGI-Feedback vom Programm <i>comments.pl</i></h1>\n";
print "<p>Perl Version: $perl_version</p>";
#print "<p>Module Version: $module_version</p>";
print "<p>Daten roh:$Daten--</p>\n";
print "<p><b>Name:</b> $Formular{username}</p>\n";
print "<p><b>pwd_laenge:</b>",length ($Formular{'pwd'}),"</p>";
print "<p><b>Pwd:</b> $Formular{pwd}</p>\n";
print "<p>Größe Text: ", length($text), "</p>\n";
print "<p>Text: $text</p>\n";
print "</body></html>\n";


## YEA YRA YEA FUnZT!

sub getstate {
	my @lines = @_;
	open (WFILE, '>', "f:\\tee.html");
	print WFILE @lines;
	close WFILE;
}