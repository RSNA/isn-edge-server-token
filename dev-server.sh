#!/bin/bash

source /etc/rsna.conf
export OPENAM_URL

bundle install
bundle exec rails server
