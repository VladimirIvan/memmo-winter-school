#!/bin/bash
docker run -it --rm -p 1234:22 -p 8888:8888 --volume="`pwd`/develop:/develop:rw" pinnochio
