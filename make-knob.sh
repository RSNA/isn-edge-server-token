#!/bin/bash

TORQUEBOX_HOME=$1
BASE_DIR=$2
export JBOSS_HOME=$TORQUEBOX_HOME/jboss
export JRUBY_HOME=$TORQUEBOX_HOME/jruby
JRUBY=$JRUBY_HOME/bin/jruby
PATH=$JRUBY_HOME/bin:$PATH
unset RUBYOPT

echo "Making knob file"
chmod +x "$JRUBY"
"$JRUBY" -S bundle install --path vendor/bundle
ISN_BUILD=1 RAILS_ENV=production "$JRUBY" -S torquebox archive --precompile-assets --package_gems "$BASE_DIR"
