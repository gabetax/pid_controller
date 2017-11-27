
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pid_controller/version"

Gem::Specification.new do |spec|
  spec.name          = "pid_controller"
  spec.version       = PidController::VERSION
  spec.authors       = ["Gabe Martin-Dempesy"]
  spec.email         = ["gabetax@gmail.com"]

  spec.summary       = %q{A Ruby PID controller implementation}
  spec.homepage      = "https://github.com/gabetax/pid_controller"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.51"
end
