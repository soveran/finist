Gem::Specification.new do |s|
  s.name = "finist"
  s.version = "0.1.0"
  s.summary = %{Redis based Finite State Machine}
  s.description = %Q{Finist is a finite state machine that is defined and persisted in Redis.}
  s.authors = ["Michel Martens"]
  s.email = ["michel@soveran.com"]
  s.homepage = "https://github.com/soveran/finist"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_dependency "redic"
  s.add_development_dependency "cutest"
end
