require 'logger'

module Habu
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::DEBUG
end
