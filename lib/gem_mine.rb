# frozen_string_literal: true

require "version_gem"

require_relative "gem_mine/version"

module GemMine
  class Error < StandardError; end
  # Your code goes here...
end

GemMine::Version.class_eval do
  extend VersionGem::Basic
end
