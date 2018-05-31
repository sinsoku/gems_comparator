# frozen_string_literal: true

module StubOctokit
  class Request
    HEADERS = { 'Content-Type' => 'application/json' }.freeze

    def initialize(method, path)
      @method = method
      @path = "https://api.github.com#{path}"
    end

    def to_return(body: '', status: 200, headers: {})
      WebMock
        .stub_request(@method, @path)
        .to_return(body: body, status: status, headers: HEADERS.merge(headers))
    end
  end

  module Helper
    def stub_octokit(method, path)
      Request.new(method, path)
    end
  end
end

RSpec.configure do |config|
  config.include StubOctokit::Helper
end
