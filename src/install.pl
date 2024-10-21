#!/usr/bin/perl -w
#=======================================================
#           INSTALL ROUTINE FOR "NMGC"
#=======================================================
$pwd  = `pwd` ; 
chop($pwd) ;
print"\n";
print "Installing the Nautilus Multi-Grain Code (NMGC) from:\n  '$pwd'\n";
$home = $ENV{"HOME"};
$bin  = $home . "/bin" ;

if(!(-e $bin)) {
    print "You must have a bin/ directory in your home directory\n" ;
    print "-----Do you want to make a $bin (y/n)?\n" ;
    $input = <STDIN> ;
    print $input ;
    if($input=~/^[yY]/) {
	print "Creating $bin...\n" ;
	system("mkdir $bin") ;
    }
}

print "  Creating a link 'nmgc' in '$bin/'\n" ;
$nmgc    = $pwd . "/nmgc" ;
$nmgclnk = $bin . "/nmgc" ;
if(!(-e $nmgclnk)) {
    print "IMPORTANT: file $nmgclnk did not exist previously. \n" ;
}
open(FILE,">$nmgclnk") || die "Could not open file\n" ;
print FILE "#!/usr/bin/perl\n" ;
print FILE "system(\"$nmgc \@ARGV\");" ;
close (FILE) ;
`chmod u+rwx $nmgclnk` ;

print "You might want to type rehash.\n";



$PATH = $ENV{"PATH"};
if(!($PATH =~ /$bin/)) {
    print "The $bin directory exists, but it not in the PATH environment variable\n" ;
    print "You must put the $bin directory in the path yourself after this installation is done.\n" ;
    print "Add the following line in your bash profile: \n" ;
    print "export PATH=$bin:$PATH" ;
    print "Don't forget to type source <your bash profile> and rehash in a terminal.\n";

}


# 
# if(!(-e $profile)) {
#     print "It would be better if you had a $profile in your home directory\n" ;
#     print "-----Please, create $home/.zshrc and come back here again.\n" ;
# }

#system("source ~/.zshrc");
#system("rehash");

