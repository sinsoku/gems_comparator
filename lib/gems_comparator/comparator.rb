# frozen_string_literal: true

module GemsComparator
  class Comparator
    def self.convert(gems)
      parallel_map(gems, &:to_h)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    private_class_method def self.parallel_map(items, max: 10)
      threads = [items.size, max].min
      work = items.each_with_index.to_a
      done = Array.new(items.size)
      workers = Array.new(threads).map do
        Thread.new do
          loop do
            item, i = work.pop
            break unless i

            done[i] =
              begin
                yield item
              rescue StandardError => e
                work.clear
                e
              end
          end
        end
      end
      workers.each(&:join)
      done.each { |d| raise d if d.is_a?(StandardError) }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def initialize(before_lockfile, after_lockfile)
      @before_lockfile = before_lockfile
      @after_lockfile = after_lockfile
    end

    def compare
      gems = addition_gems + change_gems
      Comparator.convert(gems.sort_by(&:name))
    end

    private

    def parse_lockfile(lockfile)
      parser = Bundler::LockfileParser.new(lockfile)
      parser.specs.map { |spec| [spec.name, spec.version] }.to_h
    end

    def before_gems
      @before_gems ||= parse_lockfile(@before_lockfile)
    end

    def after_gems
      @after_gems ||= parse_lockfile(@after_lockfile)
    end

    def addition_gems
      names = after_gems.keys - before_gems.keys
      names.map { |name| new_geminfo(name) }
    end

    def change_gems
      names = before_gems.keys.reject do |name|
        before_gems[name] == after_gems[name]
      end
      names.map { |name| new_geminfo(name) }
    end

    def new_geminfo(name)
      GemInfo.new(name, before_gems[name].to_s, after_gems[name].to_s)
    end
  end
end
