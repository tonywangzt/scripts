#!/usr/bin/perl
use warnings;
use strict;

my $self = {
	ffmpeg		=> '/usr/bin/ffmpeg',
	source_dir	=> '/data/video',
	dest_dir	=> '/data/public',
	tmp_dir		=> '/tmp/video',
} ;

sub ffmpeg_build {
	my ( $ffmpeg, $input_file, $output_file ) = @_;
	my $build_command = qq( $ffmpeg -y -i $input_file  -strict experimental -acodec aac   -ac 2 -ar 22050 -b 300k -vcodec libx264 -cqp 28 -coder 1 -refs 3 -deblockalpha 1 -deblockbeta -1 -me_method umh -subq 7 -me_range 32 -trellis 1 -chromaoffset -2 -nr 0 -bf 4 -b_strategy 1 -bframebias 0 -directpred 3 -g 250 -i_qfactor 1.3 -b_qfactor 1.4 -flags2 +bpyramid+wpred+mixed_refs+8x8dct -er 2 -threads 4  $output_file );
	readpipe( $build_command );
	unlink $input_file;
}

while ( 1 < 2 ) {
	opendir my $dh , $self->{source_dir} or die "$!";
	my @video_file 
			= 	grep  	{ !/^\./ 				} 
				map		{ $_->[0] 				} 
				sort 	{ $a->[1] <=> $b->[1]	} 
			 	map 	{ [ $_ , ( stat("$self->{source_dir}/$_") )[9] ] } readdir $dh;
	
	if ( @video_file > 1 ){
		for ( 0..( $#video_file -1 ) ){
			my $ffmpeg		=  $self->{ffmpeg};
			my $input_file	= "$self->{source_dir}/$video_file[$_]";
			my $output_file	= "$self->{dest_dir}/$video_file[$_]";
			ffmpeg_build( $ffmpeg, $input_file, $output_file ); 
		}
	}
	
	closedir $dh;
	sleep 300;
}
