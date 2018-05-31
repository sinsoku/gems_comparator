# frozen_string_literal: true

require 'bundler'
require 'octokit'

require 'gems_comparator/comparator'
require 'gems_comparator/config'
require 'gems_comparator/gem_info'
require 'gems_comparator/github_repository'
require 'gems_comparator/version'

module GemsComparator
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  def self.compare(before_lockfile, after_lockfile)
    Comparator.new(before_lockfile, after_lockfile).compare
  end
end
