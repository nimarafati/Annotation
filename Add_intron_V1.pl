#!/usr/bin/perl
use Getopt::Long;

my $contact="Nima Rafati nimarafati\@gmail.com
20180512 V1.0\n";
my $usage="$0 -gff 
This script extracts intron fron gff/bed file.
-gff gff file
-bed bed file; Bed file format should extended (e.g. 1 29553 30039 + exon lincRNA MIR1302-2HG ENSG00000243485.5_3)
$contact\n";

&GetOptions('h' =>\$helpFlag,
'gff=s' =>\$gffFile,
'bed=s' =>\$bedFile);

my @lineArr=();
my $cntr=0;

if($gffFile ne "")
{
	open (inF0,$gffFile);
}
elsif($bedFile ne "")
{
	open (inF0,$bedFile);
}
while(<inF0>)
{
$cntr++;
	if($_=~ /#/)
	{
#		print $_;<STDIN>;
	}
	else
	{
		chomp($_);
		if($bedFile ne "")
		{
#			print "BED format\n";
			#******** ccheck the space type in input file
			@lineArr=split(" ",$_);
			#1 29553 30039 + exon lincRNA MIR1302-2HG ENSG00000243485.5_3
			$chr=$lineArr[0];
			$start=$lineArr[1];
			$end=$lineArr[2];
			$strand=$lineArr[3];
			$feature=$lineArr[4];
			$type=$lineArr[5];
			$gene_name=$lineArr[6];
			$transcript_id=$lineArr[7];
			if($prv_transcript_id eq $transcript_id)
			{
				if($strand eq "+")
				{
					$startIntron=$prv_end;
					$endIntron=$start;
				}
				else
				{
					$startIntron=$prv_start;
					$endIntron=$end;	
				}
				print "$chr $startIntron $endIntron $strand intron $type $gene_name $transcript_id\n";
			}
		}
		else
		{
			@lineArr=split("\t",$_);
#		chr1	HAVANA	gene	11869	14409	.	+	.	ID=ENSG00000223972.5;transcript_id=ENSG00000223972.5_2;gene_type=transcribed_unprocessed_pseudogene;gene_name=DDX11L1;level=2;havana_gene=OTTHUMG00000000961.2_2;remap_status=full_contig;remap_num_mappings=1;remap_target_status=overlap
#		chr1	HAVANA	transcript	11869	14409	.	+	.	ID=ENST00000456328.2;Parent=ENSG00000223972.5;transcript_id=ENSG00000223972.5_2;transcript_id=ENST00000456328.2_1;gene_type=transcribed_unprocessed_pseudogene;gene_name=DDX11L1;transcript_type=processed_transcript;transcript_name=DDX11L1-002;level=2;transcript_support_level=1;tag=basic;havana_gene=OTTHUMG00000000961.2_2;havana_transcript=OTTHUMT00000362751.1_1;remap_num_mappings=1;remap_status=full_contig;remap_target_status=overlap
			$chr=$lineArr[0];
			$start=$lineArr[3];
			$end=$lineArr[4];
			$strand=$lineArr[6];
			$feature=$lineArr[2];
			$info=$lineArr[8];
			@infoArr=split(";",$info);

		
			for(my $i=0;$i<scalar(@infoArr);$i++)
			{
				if($infoArr[$i]=~ m/gene_type=(.*)/)
				{
					$type=$1;
				}
				if($infoArr[$i]=~ m/transcript_id=(.*)/)
				{
					$transcript_id=$1;
				}
				if($infoArr[$i]=~ m/gene_name=(.*)/)
				{
					$gene_name=$1;
				}
			}
			if($feature eq "transcript")
			{
#				print "$info\n$gene_name $transcript_id $type";<STDIN>;
				if($strand eq "+")
				{
					$startPromoter=$start-2001;
					$endPromoter=$start-1;
					print "$chr $startPromoter $endPromoter $strand promoter $type $gene_name $transcript_id\n"
				}
				if($strand eq "-")
				{
					$endPromoter=$end+2000;
					$startPromoter=$end;
					print "$chr $startPromoter $endPromoter $strand promoter $type $gene_name $transcript_id\n";
				}
			}
			if($feature eq "CDS")
			{
				if($prv_exon_transcript_id ne $transcript_id)
				{
					print "$chr ",$start-1," $end $strand CDS $type $gene_name $transcript_id\n";
				}
				elsif($prv_exon_transcript_id eq $transcript_id)
				{
					if($strand eq "+")
					{
#						print "$prv_rec\n$start-$end-$prv_end\n$_";<STDIN>;
						$startIntron=$prv_end;
						$endIntron=$start-1;
					}
					if($strand eq "-")
					{
						$endIntron=$prv_start-1;
						$startIntron=$end-1;
					}
					print "$chr $startIntron $endIntron $strand intron $type $gene_name $transcript_id\n";
					print "$chr ",$start-1," $end $strand CDS $type $gene_name $transcript_id\n";
				}
				$prv_exon_transcript_id=$transcript_id;
			}
			if($feature eq "exon")
			{
				if($prv_exon_transcript_id ne $transcript_id)
				{
					print "$chr ",$start-1," $end $strand exon $type $gene_name $transcript_id\n";
				}
				elsif($prv_exon_transcript_id eq $transcript_id)
				{
					if($strand eq "+")
					{
#						print "$prv_rec\n$start-$end-$prv_end\n$_";<STDIN>;
						$startIntron=$prv_end;
						$endIntron=$start-1;
					}
					if($strand eq "-")
					{
						$endIntron=$prv_start-1;
						$startIntron=$end-1;
					}
					print "$chr $startIntron $endIntron $strand intron $type $gene_name $transcript_id\n";
					print "$chr ",$start-1," $end $strand exon $type $gene_name $transcript_id\n";
				}
				$prv_exon_transcript_id=$transcript_id;
			}
			if($feature=~ m/.*UTR*/)
			{
				print "$chr $start $end $strand $feature $type $gene_name $transcript_id\n";
			}
		}
		$prv_rec=$_;
		$prv_transcript_id=$transcript_id;
		$prv_start=$start;
		$prv_end=$end;
	}
	
}
