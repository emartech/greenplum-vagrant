#!/bin/sh

until [ "0" == "$(gpstate -q; echo $?)" ]; do sleep 5; done
