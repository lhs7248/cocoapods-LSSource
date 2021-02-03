#!/bin/sh
gem build cocoapods-LSSource.gemspec

gem uninstall cocoapods-LSSource

gem install --local cocoapods-LSSource-0.0.1.gem