# frozen_string_literal: true
module GemsComparator
  class GithubRepository
    def self.repo?(url)
      Octokit::Repository.from_url(url)
      true
    rescue
      false
    end

    def initialize(url)
      @repo = Octokit::Repository.from_url(url)
    end

    def compare(base, head)
      base_tag = find_tag(base)
      head_tag = find_tag(head)

      if base_tag && head_tag
        "#{@repo.url}/compare/#{base_tag.name}...#{head_tag.name}"
      elsif base_tag
        "#{@repo.url}/compare/#{base_tag.name}...master"
      end
    end

    private

    def tags
      @tags ||= client.tags(@repo)
    end

    def find_tag(name)
      tags.find { |tag| ["v#{name}", name].include?(tag.name) }
    end

    def client
      GemsComparator.config.client
    end
  end
end
