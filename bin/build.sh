#!/bin/bash
clear

mvn install 2>&1 | tee build.log
