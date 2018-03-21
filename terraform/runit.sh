#!/usr/bin/env bash

terraform plan -var-file $1 -out out.tfplan