#!/bin/bash
echo "remaining mpi fluent processes"
ps -aux | grep fluent_mpi

echo "killing remaining fluent processes"
for proc in $(pgrep fluent_mpi); do kill -9 $proc; done

echo "remaining mpi fluent processes after the kill"
ps -aux | grep fluent_mpi

echo "end of coordination"
echo "======================================================="
