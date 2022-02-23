# frozen_string_literal: true

module GemsComparator
  class GithubRepository
    def self.repo?(url)
      return false unless url.include?('github.com')

      Octokit::Repository.from_url(url)
      true
    rescue StandardError
      false
    end

    def initialize(url)
      @repo = Octokit::Repository.from_url(url)
    end

    def compare(base, head)
      base_tag = find_tag(base)
      head_tag = find_tag(head)

      if base_tag && head_tag
        "#{@repo.url}/compare/#{base_tag}...#{head_tag}"
      elsif base_tag
        "#{@repo.url}/compare/#{base_tag}...master"
      end
    end

    private

    def tag_names
      @tag_names ||= client.tags(@repo).map(&:name)
    end

    def find_tag(name)
      return if name.empty?

      tag_names.find { |tag_name| tag_name.end_with?(name) }
    end

    def client
      GemsComparator.config.client
    end
  end
end
