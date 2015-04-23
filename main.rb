#!/usr/bin/ruby

require "yaml"
require "optparse"

require "./account.rb"
require "./logger.rb"
require "./plugin.rb"

OPTS = ARGV.getopts("", "log-file:/dev/stdout", "log-level:info").freeze

module TwitterBot
  class Client
    def initialize
      @threads = load_tokens("./config.yml")
    end

    def load_tokens(file)
      threads = []

      tokens = YAML.load_file(file)
      tokens.each do |token|
        token.each_value do |v|
          v.freeze
        end
        threads << create_thread(token)
      end

      threads
    end

    def create_thread(token)
      Thread.new do
        account = Account.new(token)
        files = Dir.glob(File.expand_path("../plugins/*.rb", __FILE__))
        files.each do |file|
          account.add_plugin(file)
        end
        account.start
      end
    end

    def start_all
      @threads.each do |th|
        th.join
      end
    end
  end
end

bot = TwitterBot::Client.new
bot.start_all
