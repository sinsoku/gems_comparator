# frozen_string_literal: true

require 'yaml'

module GemsComparator
  class GemInfo
    GITHUB_URLS_PATH = File.join(__dir__, '../../data/github_urls.yml')

    attr_reader :name, :before, :after

    def initialize(name, before, after)
      @name = name
      @before = before
      @after = after
    end

    def compare_url
      return unless github_url

      repo = GithubRepository.new(github_url)
      repo.compare(before, after)
    rescue StandardError => e
      e.inspect
    end

    def github_url
      if GithubRepository.repo?(homepage)
        homepage
      elsif github_urls.key?(name)
        "https://github.com/#{github_urls[name]}"
      end
    end

    def homepage
      spec&.homepage
    end

    def to_h
      attr_names = %i[name before after homepage github_url compare_url]
      attr_names.map { |m| [m, send(m)] }.to_h
    end

    private

    def github_urls
      @github_urls ||= YAML.load_file(GITHUB_URLS_PATH)
    end

    def spec
      @spec ||= Gem::Specification.load(spec_path)
    end

    def spec_path
      spec_paths = [
        "#{Bundler.specs_path}/#{name}-#{before}.gemspec",
        "#{Bundler.specs_path}/#{name}-#{after}.gemspec"
      ]
      spec_paths.find { |path| File.exist?(path) }
    end
  end
end
