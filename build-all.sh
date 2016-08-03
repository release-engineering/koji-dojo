#!/bin/bash

for c in hub client builder; do
	echo "Building $c"
	${c}/docker-scripts/build.sh
done
