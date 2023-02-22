#!/usr/bin/env ruby
$VERBOSE = nil

require_relative "lib/status"
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
Status.new.check
