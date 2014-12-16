#!/usr/bin/perl
use warnings;
use strict;
###当磁盘剩余空间小于avail_size,删除大于expire_time 的文件,但一次最多删除delete_size 数量的文件

my $video_dir	= '/data/public';
my @disk_stat	= readpipe("df -h");
my $expire_time	= 90 ;
my $avail_size	= 50;
my $delete_num	= 50;

my $delete_file  = sub {
	my $video_dir  = shift;
	my $delete_init= 1;
	opendir my $d , $video_dir or die "$!";

	while ( my $line = readdir $d ){
		next  if  "$line" =~ /^\./	;
		my $file  = "$video_dir/$line";

		if  ( -M $file  > $expire_time ) {
			$delete_init  < $delete_num ? $delete_init++ : exit 0;
			unlink $file;
		}
	}
	
	closedir $d;
};


for my $stat (@disk_stat){
	if  ( $stat =~ /^\/.*(?:\s+\d+G){2}\s+(\d+)G\s+\d+%\s+\/$/ ){
		my $now_avail_size = $1;
		$delete_file->($video_dir)	if  $now_avail_size <  $avail_size;
	}
}