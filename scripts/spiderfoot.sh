#!/usr/bin/env bash
sudo docker run -p 5009:5001 -d spiderfoot
firefox http://localhost:5009
