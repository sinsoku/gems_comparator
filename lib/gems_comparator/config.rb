# frozen_string_literal: true
module GemsComparator
  class Config
    attr_accessor :client

    def initialize
      @client = Octokit::Client.new
    end
  end
end
