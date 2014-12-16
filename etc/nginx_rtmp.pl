#--prefix=/usr/local/nginx --add-module=../nginx-rtmp-module/ --with-file-aio --with-http_sub_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_mp4_module --with-http_flv_module --with-http_gunzip_module --with-http_image_filter_module


worker_processes  1;

error_log  logs/error.log debug;

events {
    worker_connections  2048;
}
http {
	server {
		listen  88; 
		location /status {
			stub_status on;
		}
	}
	
		
}



rtmp {
    server {
        listen 1935;

        application myapp {
            live on;

            #record keyframes;
            #record_path /tmp;
            #record_max_size 128K;
            #record_interval 30s;
            #record_suffix .this.is.flv;

            #on_publish http://localhost:8080/publish;
            #on_play http://localhost:8080/play;
            #on_record_done http://localhost:8080/record_done;
        }

		application mylinuxsa {
			live	on;
			hls		on;
			hls_path	/data/app;
			hls_fragment	10s;
		}
		application hls {
			live	on;
			hls		on;
			hls_path	/data/app;
			hls_fragment	10s;
		}
    }
}

http {
    server {
        listen      80;

        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }

        location /stat.xsl {
            root /path/to/nginx-rtmp-module/;
        }

        location /control {
            rtmp_control all;
        }

        #location /publish {
        #    return 201;
        #}

        #location /play {
        #    return 202;
        #}

        #location /record_done {
        #    return 203;
        #}

	location /hls {
		types {
			application/vnd.apple.mpegurl m3u8;
			video/mp2t 					  ts;
		}
		alias /data/app;
		expires	-1;
	}
	location /mylinuxsa {
		types {
			application/vnd.apple.mpegurl m3u8;
			video/mp2t 					  ts;
		}
		alias /data/app;
		expires	-1;
	}
	location /hls2 {
		types {
			application/vnd.apple.mpegurl m3u8;
			video/mp2t 					  ts;
		}
		alias /data/;
		expires	-1;
	}
        location /rtmp-publisher {
            root /path/to/nginx-rtmp-module/test;
        }

        location / {
            root /path/to/nginx-rtmp-module/test/www;
        }
    }
}
