# keep order
require "examity_client/version"
require "examity_client/configuration"
require "examity_client/client"
require "examity_client/error"
require "examity_client/user"
require "examity_client/course"
require "examity_client/exam"
require "examity_client/appointment"
require "examity_client/flag"
require "examity_client/test_api_server"

require "rest-client"
require "awesome_print"
require "active_support/core_ext/hash"
require "logger"

module ExamityClient
  # https://prod.examity.com/trueabilityapi/help

  class << self
    attr_writer :configuration
  end

  def self.configuration(initialization_opts = {})
    @configuration ||= Configuration.new(initialization_opts)
  end

  def self.configure(initialization_opts = {})
    config = configuration(initialization_opts)
    yield(config) if block_given?
  end
end
