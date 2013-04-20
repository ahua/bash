#!/usr/bin/env bash

for i in {1..5}; do
  echo $i;
done

END=5
for i in `seq 1 $END`; do 
  echo $i;
done

END=5
i=1
while [[ $i -le $END ]]; do
  echo $i
  ((i = i + 1))
done

END=5
for (( i = 1; i <= END; i++ )); do 
  echo $i
done

