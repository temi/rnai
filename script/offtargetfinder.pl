#!/usr/bin/perl -Wall

#usage >perl offtargettesting_bwt_blast_siScore.pl <query.tsv> <num_mismatches>


=cut

=head1 TODO

#TODO
http://nar.oxfordjournals.org/content/32/suppl_2/W130.full
an algorithm for mapping the siRNA to the genomic sequences and indicate to the user if the siRNA is at an exon–exon junction or if the siRNA contains any SNPs

=cut

=pod

=head1 NAME

evaluate_RNAi.pl v0.01

=head1 USAGE

Mandatory:


 -file|fasta|query :s  => Sequence to design RNAi for.
 -md5 :s	       => md5 of query string

Optional:

 -database :s          => Transcriptome/gene models to search against.
 -mismatches 0-3       => Number of mismatches allowed. Defaults to 0.
 -dir :s               => Directory for databases (defaults to current).
 -cpus|threads :i      => Maximum number of CPUs to use (defaults to 2).
 -k :i                 => Size of kmer for RNAi design (defaults to 21).
 -uid :s               => unique identifier to create output (defaults to a non-existent random)
 -outdir:s => output directory
-dbhost:s  =>  host location of database
 -dbuser:s => database username
 -dbpass:s=> database password
 -dbname:s=> db name,
 -port:i => db port
=cut

use strict;
use warnings;
use Getopt::Long;
use Digest::MD5 qw(md5_hex);
use Pod::Usage;
use JSON;
use DBI;

use Data::Dumper;

my ( $database, $query_file, $help,$uid, $md5,$out_dir ,$db_host ,$db_user ,$db_pass ,$db_name ,$port  );
my $mismatches = int(0);
my $database_dir = `pwd`;chomp($database_dir);
my $cpus         = 2;
my $mer_size     = 21;
my ($rVal, $stmt);
my ($makeblastdb_exec,$bowtie_build_exec,$bowtie_exec,$blastdbcmd_exec,$blastx_exec) = &check_program('makeblastdb','bowtie-build','bowtie','blastdbcmd','blastx');

GetOptions(
            'mismatches:i'       => \$mismatches,
            'database:s'         => \$database,
            'file|fasta|query:s' => \$query_file,
            'dir:s'              => \$database_dir,
            'cpus|threads:i'             => \$cpus,
            'k:i'                => \$mer_size,
            'help'              => \$help,
            'uid:s'             => \$uid,
	        'md5:s'             => \$md5,
	        'outdir:s'          => \$out_dir,
            'dbhost:s'          => \$db_host,
            'dbuser:s'          => \$db_user ,
            'dbpass:s'          => \$db_pass,
            'dbname:s'          => \$db_name,
            'port:i'            => \$port
);

pod2usage if $help;

#pod2usage "Database not given (-data) \n"   unless $database;
pod2usage"No query sequence provided (-query) \n"  unless $query_file && -s $query_file;
pod2usage "Please give a md5 value for the query \n"   unless $md5;

#this is the value for this program. initializing again to rewrite any other value given at commandline.
$mer_size = 21;

while (!$uid || -d $uid ) {
 $uid = 'RNAi_' .md5_hex( time() . 'RNAi' );
}
$out_dir =$out_dir.'/'.$uid;
print $out_dir;
mkdir($out_dir);

#find all databases/genomes
my $db = "dbi:Pg:dbname=${db_name};host=${db_host};port=${port}";
my $dbh = DBI->connect($db, $db_user, $db_pass,{ RaiseError => 1 }) || die "Error connecting to the database: $DBI::errstr\n";
my $query = "SELECT * FROM genome where filename is not null limit 6";
my $ref = $dbh->selectall_hashref($query,'id');
# variable stores the database id of each database
my $dbid;
#temp variable
my $value;


#my @databases = qw(
#  ACPmRNA
#  Essigella_californica.fa
#  Meinertellus_cundinamarcensis.fa
#  Machilis_hrabei.fa
#  Zygonyx_iris.fa
#);

my $dsRNA      = 0;
my $offTarget  = 0;
my @dsRNA      = ();
my $dsRNA_Name = 0;
my @fields     = ();
open IN, $query_file;    #targets in tab delimitted format
my $mm = $mismatches;
my $regionStmt;
my ($start,$end);
while (<IN>) {
    my @line = split /\t/, $_;

    ( $dsRNA_Name, $dsRNA ) = @line;
    @dsRNA = split "", $dsRNA;
    open BWTIN, (">$out_dir/bowtiein.fasta");    # make a little fasta file of all the 21 mers in the query
    for ( my $i = 0 ; $i < @dsRNA - 21 ; $i++ ) {
      my @off = @dsRNA[ $i .. $i + 20 ];
      $offTarget = join "", @off;
      print BWTIN ">$dsRNA_Name" . "_Pos$i\n$offTarget";
    }
    close BWTIN;
    open OUT1, ( ">$out_dir/results1_$dsRNA_Name" . ".XY" );    #
    print OUT1 "Database\tHits";
    open OUT2, ( ">$out_dir/results2_$dsRNA_Name" . ".hitloc" );
    print OUT2 ("Query\tDatabase\tContig\tNearestMelProt");
    foreach my $key (keys %{ $ref }) {
        $value = $ref->{$key};
        $dbid = $value->{'id'};
        #  print Dumper( $value );
        $database = $value->{'filename'};
        $regionStmt = $dbh->prepare("insert into regions(md5,dbid,starting,ending,mismatches) values(?,?,?,?,?)");
#    foreach $database (@databases) {
#        print "$database";
        my $count     = 0;
        my @offTargIn = ();
        open OUT4, ( ">$out_dir/$dsRNA_Name" . "_offtargetsCAP_$database.fa" );
        open OUT3, ( ">$out_dir/$dsRNA_Name" . "_offtargets_to_" . "$database" . ".XY" );
        print OUT3 "Query\tTarget";


        system(
"bowtie  -f $database_dir/$database $out_dir/bowtiein.fasta --quiet -p 8 -v $mm -a >$out_dir/$dsRNA_Name"
              . "_$database"
              . ".bwt" );    # align the little fasta file

        if ( -s "$out_dir/$dsRNA_Name" . "_$database" . ".bwt" )
        {                    # analyse hits to target
            open RESULT, ( "<$out_dir/$dsRNA_Name" . "_$database" . ".bwt" );
            open FASTA,  ( ">$out_dir/$dsRNA_Name" . "_$database" . ".fasta" );
            push @offTargIn,
              $dsRNA;   #put sequence of target into array for CASING offtargets

            my @out3        = ();
            my @uni_contigs = qw(z);    #initialise
            while (<RESULT>) {
                $count++;
                my $uni_contigsearch = join "\t",
                  @uni_contigs;         #make array searchable
                @fields = split "\t", $_;
                my @pos = split "_", $fields[0];    #get numeric value of 21mer
                $pos[ @pos - 1 ] =~ s/Pos//;
                $start = $pos[ @pos - 1 ];
                $end = $start + $mer_size;
                push @offTargIn, $pos[ @pos - 1 ];    #start of offtargets
                my $out = ("$fields[2]\t$pos[@pos-1]\t$fields[3]");
                push @out3, $out;

                $regionStmt->execute( $md5, $dbid, $start, $end, $fields[7] ) or warn "Can't execute SQL statement: $DBI::errstr\n";

                if ( $uni_contigsearch !~ $fields[2] ) {
                    push @uni_contigs, $fields[2];
                }    #get rid of duplicate targets
                my $siRNA_Score =
                  siRNA_scorer( $fields[4] )
                ;    #evaluate reynolds rules for each matching 21mer
                if ( $siRNA_Score > 5 ) {
                    print FASTA
                      ">$fields[0] Reynolds score = $siRNA_Score\n$fields[4]";
                }
            }
            #why is this needed? is anything done with OffCAPseq? it seems it is just writing the sequence to files.
            #start not needed?
            my $OffCAPseq =
              CAP_offTarg(@offTargIn);    #subroutine for marking offtargets
            undef @offTargIn;
            print OUT4 ">$database" . "_$dsRNA_Name\n$OffCAPseq";
            #end not needed?

            my @sorted_out3 = sort {
                ( split /\t/, $a )[0] cmp( split /\t/, $b )[0]
                  || ( split /\t/, $a )[1] <=> ( split /\t/, $b )[1]
            } @out3;    #sort an array by the various fields in a string

            foreach my $out3 (@sorted_out3) {
                print OUT3 "$out3";
            }

            close FASTA;
            close OUT3;

            shift @uni_contigs;    #get rid of z
             # contigs maybe get a range i.e. how long the match is ask charlie what he'd like to see??
            #foreach my $contig (@uni_contigs) {
             #   system(
#" blastdbcmd -db $database_dir/$database -entry $contig -out temp"
#                );
#                system(
#"blastx -db $database_dir/MEL_PROT -query temp -outfmt 6 -max_target_seqs 1 -num_threads 8 >$out_dir/$dsRNA_Name"
#                      . "_$database"
#                      . ".blastout" );
#                open BLASTOUT, ( "<$out_dir/$dsRNA_Name" . "_$database" . ".blastout" );
#                while (<BLASTOUT>) {
#                    my @mel_match = split "\t", $_;
#                    print OUT2
#                      " $dsRNA_Name\t$database\t$contig\t$mel_match[1]";
#                }    #blastout while

# do stuff with temp2 like find the name of the protein and put it in a file sort it maybe
#maybe this is stuff for OUT2 print OUT2 "$result[0]\t$result[9] ....."; #select appropriate fields ir sequence gene it hits where in the gnen it hits ...

#            }    #result while
            close RESULT;
          #  system( " rm -rf $dsRNA_Name"
           #       . "_$database"
            #      . ".bwt $database"
             #     . ".blastout" );
        }    #if file not 0

        print OUT1 "$database\t$count";
        if( $count ){
            $stmt = $dbh->prepare("insert into hits(md5,dbid,hits) values('$md5',$dbid,$count)");
            $rVal = $stmt->execute( ) or warn "Can't execute SQL statement: $DBI::errstr\n";
        }

    }    #foreach
    close OUT1;
    close OUT4;
    close OUT2;
    #we do not need to run the r script
    #start not needed
#    open OUTR, (">$out_dir/script.R");
#    print OUTR " library(png)\n
#plot = read.table(\"results1_$dsRNA_Name.XY\",header=T)\n
#jpeg(filename=\"mm$mm"
#      . "results1_$dsRNA_Name.jpg\",height=495, width =700, bg = \"white\" )\n
#barplot((plot\$Hits+1),names.arg=plot\$Database,main = \"$dsRNA_Name\($mm mm\) \" ,ylim=c(2,500),log=\"y\",xlab=\"Database\",ylab=\"No of hits\" )\n
#dev.off()\n
#quit()";
#    close OUTR;
#    system("Rscript script.R");
#    system( "cat *.fa >$out_dir/$dsRNA_Name" . "offCAPS.fasta" );
#    system("rm -rf *fa");
    #end not needed
}    #while

sub siRNA_scorer {
    my $dsRNA = shift;
    my @dsrna = split "", $dsRNA;

    my $score = 0;

    if ( $dsrna[18] eq "A" ) { $score++; }    #rule 4
    if ( $dsrna[2]  eq "A" ) { $score++; }    #rule 5
    if ( $dsrna[9]  eq "T" ) { $score++; }    #rule 6
    if ( $dsrna[18] eq "G" ) { $score--; }    #rule 7
    if ( $dsrna[12] eq "G" ) { $score--; }    #rule 8
    if ( $dsrna[18] eq "C" ) { $score--; }    #rule 7
    my $gc   = 0;
    my $tpat = 0;

    foreach my $base (@dsrna) {

        if ( $base eq "C" || $base eq "G" ) { $gc++; }

    }
    $gc = $gc / 21;

    if ( $gc <= .5 && $gc >= .3 ) { $score++; }    #rule 1

    for ( my $i = 14 ; $i < 19 ; $i++ ) {
        if ( $dsrna[$i] eq "A" || $dsrna[$i] eq "T" ) { $tpat++; }
    }
    if ( $tpat > 2 ) { $score = $score + $tpat; }    #rule 2
    my $Tm =
      79.8 +
      18.5 * log10(.05) +
      ( 58.4 * $gc ) +
      11.8 * $gc * $gc -
      ( 820 / 21 );                                  #rule 3
    if ( $Tm < 20 ) { $score++; }

    return $score;

    sub log10 {
        my $n = shift;
        return log($n) / log(10);
    }

}

#subroutine for UPPER casing offTargets
sub CAP_offTarg {
    my $input = shift @_;

    #print "$input";
    my @oseq = split "", $input;
    my @seq  = split "", $input;
    my @rseq = @oseq;

    #print "\@oseq = (@oseq)\n"; how to print an array in brackets!!!!

    foreach my $pos (@_) {
        @oseq = @rseq;
        my @offTarg = splice( @oseq, $pos, 21 );
        my $offtarg = join "", @offTarg;
        $offtarg = uc($offtarg);
        my @offtarg = split "", $offtarg;
        splice( @seq, $pos, 21, @offtarg );
    }
    my $seq = join "", @seq;

    #print "$seq";
    return $seq;
}
# insert regions to table
sub insertRegions {
 my ($dbh,$md5,$dbid, @regions) = @_;
 my (@temp,$i);
 my $stmt = $dbh->prepare("insert into regions(md5,dbid,starting,ending) values(?,?,?,?)");
  for ( $i = 0 ; $i < @regions; $i++ ) {
  $stmt->execute( $md5, $dbid,$regions[$i][0],$regions[$i][1]) or warn "Can't execute SQL statement: $DBI::errstr\n";
 }
}
# check if the required programs exist
sub check_program() {
 my @paths;
 foreach my $prog (@_) {
  my $path = `which $prog`;
  pod2usage "Error, path to a required program ($prog) cannot be found\n\n"
    unless $path =~ /^\//;
  chomp($path);
  $path = readlink($path) if -l $path;
  push( @paths, $path );
 }
 return @paths;
}
