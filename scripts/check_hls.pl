#!/usr/bin/perl
use warnings;
use strict;
use LWP;

my $ffmpeg_command = qq(
	ffmpeg -y -i rtmp://live.mylinuxsa.com/mylinuxsa/live1  -strict experimental -acodec aac   -ac 2 -ar 22050 -b 300k -vcodec libx264 -cqp 28 -coder 1 -refs 3 -deblockalpha 1 -deblockbeta -1 -me_method umh -subq 7 -me_range 32 -trellis 1 -chromaoffset -2 -nr 0 -bf 4 -b_strategy 1 -bframebias 0 -directpred 3 -g 250 -i_qfactor 1.3 -b_qfactor 1.4 -flags2 +bpyramid+wpred+mixed_refs+8x8dct -er 2 -vol 1024 -threads 4  -f flv rtmp://123.123.123.123/hls/mystream
);

my $restart  = sub {
	my $sleep_time = shift;
	my $ffmpeg_pid ;
	my @process_list	= readpipe("ps -ef");
	for my $process ( @process_list ) {
		if ( $process =~ /ffmpeg.*mylinuxsa/ ) {
			$ffmpeg_pid = (split /\s+/, $process)[1];
		}
	}
	kill 9,$ffmpeg_pid if  $ffmpeg_pid;
	readpipe( $ffmpeg_command );
	sleep( $sleep_time );
};

my $end_line = sub {
	my $m3u8_url	=  shift;
	my $ua			= LWP::UserAgent->new;
	my $response	= $ua->get($m3u8_url);
	
	my $status		=  $response->{_rc};
	return $status	if $status == 404 ;
	
	my $html		=  $response->{_content};
	my $end_line	=  (split /\s+/,$html)[-1];
	chomp($end_line);
	return $end_line;
};


my $m3u8_url	= 'http://123.123.123.123:8080/hls/mystream.m3u8';

while ( 1< 2 ) {
	my $line 	= $end_line->($m3u8_url);
	print ">>>>>>>>>>>><<<<<<<<<<<<\n";
	print "line ------> $line\n";
	
	$restart->(60)		if  $line eq "404" ;
	sleep( 21 );
	my $new_line= $end_line->($m3u8_url);
	$restart->(60)		if  $line  eq $new_line ;	

	print "new_line ------> $new_line\n";
	print ">>>>>>>>>>>><<<<<<<<<<<<\n";
	
}
