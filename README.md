[Focalboard](https://www.focalboard.com) Docker Images for Raspberry Pi (arm/v7)
====================

The images can be found at Docker Hub [`jimmymasaru/focalboard`](https://hub.docker.com/r/jimmymasaru/focalboard).
Source code can be found at GitHub [`jimmymasaru/focalboard-docker-arm`](https://github.com/jimmymasaru/focalboard-docker-arm/).

Usage
-----

### docker-compose

* `config.json`
	```
	{
		"serverRoot": "http://localhost:8000",
		"port": 8000,
		"dbtype": "sqlite3",
		"dbconfig": "/var/lib/focalboard/focalboard.db",
		"postgres_dbconfig": "dbname=focalboard sslmode=disable",
		"useSSL": false,
		"webpath": "./pack",
		"filespath": "/var/lib/focalboard/file",
		"telemetry": true,
		"prometheus_address": ":9092",
		"session_expire_time": 2592000,
		"session_refresh_time": 18000,
		"localOnly": false,
		"enableLocalMode": true,
		"localModeSocketLocation": "/var/tmp/focalboard_local.socket"
	}
	```

* `docker-compose.yml`
  ```
  services:
    focalboard:
      image: jimmymasaru/focalboard:latest
      restart: unless-stopped
      ports:
        - "8000:8000"
      extra_hosts:
        - "host.docker.internal:host-gateway"
      volumes:
      - ./config.json:/opt/focalboard/config.json
      - ./focalboard:/var/lib/focalboard
  ```
