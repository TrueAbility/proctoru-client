# keep order
require_relative "examity_client/version"
require_relative "examity_client/base"
require_relative "examity_client/configuration"
require_relative "examity_client/client"
require_relative "examity_client/error"
require_relative "examity_client/user"
require_relative "examity_client/course"
require_relative "examity_client/exam"
require_relative "examity_client/appointment"
require_relative "examity_client/flag"
require_relative "examity_client/single_sign_on"
require_relative "examity_client/test_api_server"

require "hash_ext"
require "rest-client"
require "awesome_print"
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
