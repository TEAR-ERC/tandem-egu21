#!/bin/bash
docker run --rm -t --net=host -v /home/uphoff/projects/tandem-egu21:/slides astefanutti/decktape -s 1280x720 generic http://localhost:4000/tandem-egu21/live live.pdf
