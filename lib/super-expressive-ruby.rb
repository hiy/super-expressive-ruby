require "super-expressive-ruby/version"

module SuperExpressive
  require 'super-expressive-ruby/super-expressive-ruby'
  class Error < StandardError; end

  def self.create
    SuperExpressiveRuby.new
  end
end
