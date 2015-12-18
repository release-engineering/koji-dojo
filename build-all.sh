#!/bin/bash

for c in hub client; do
	echo "Building $c"
	${c}/docker-scripts/build.sh
done
