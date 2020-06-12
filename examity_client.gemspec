lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "examity_client/version"

Gem::Specification.new do |spec|
  spec.name          = "examity_client"
  spec.version       = ExamityClient::VERSION
  spec.authors       = ["Dusty Jones"]
  spec.email         = ["dusty@trueability.com"]

  spec.summary       = %q{Internal Gem to access Examity API}

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "capybara_discoball"
  spec.add_dependency "awesome_print"
  spec.add_dependency "rest-client"
end
