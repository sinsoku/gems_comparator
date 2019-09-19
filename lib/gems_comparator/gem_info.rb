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
      @github_url ||= [
        source_code_uri,
        homepage,
        github_url_from_yaml
      ].map(&method(:normalized_github_url)).compact.first
    end

    def homepage
      spec&.homepage
    end

    def to_h
      attr_names = %i[name before after homepage github_url compare_url]
      attr_names.map { |m| [m, send(m)] }.to_h
    end

    private

    def normalized_github_url(url)
      return unless url.include?('github.com')

      Octokit::Repository.from_url(url).url
    rescue URI::InvalidURIError, Octokit::InvalidRepository, NoMethodError
      nil
    end

    def github_slugs
      @github_slugs ||= YAML.load_file(GITHUB_URLS_PATH)
    end

    def github_url_from_yaml
      "https://github.com/#{github_slugs[name]}" if github_slugs.key?(name)
    end

    def spec
      @spec ||= Gem::Specification.load(spec_path)
    end

    def spec_path
      spec_paths = [
        "#{Bundler.specs_path}/#{name}-#{after}.gemspec",
        "#{Bundler.specs_path}/#{name}-#{before}.gemspec"
      ]
      spec_paths.find { |path| File.exist?(path) }
    end

    def source_code_uri
      spec&.metadata&.fetch('source_code_uri', nil)
    end
  end
end
