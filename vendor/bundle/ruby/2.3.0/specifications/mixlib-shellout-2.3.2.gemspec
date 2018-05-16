# -*- encoding: utf-8 -*-
# stub: mixlib-shellout 2.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "mixlib-shellout"
  s.version = "2.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Chef Software Inc."]
  s.date = "2017-07-21"
  s.description = "Run external commands on Unix or Windows"
  s.email = "info@chef.io"
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["LICENSE", "README.md"]
  s.homepage = "https://www.chef.io/"
  s.required_ruby_version = Gem::Requirement.new(">= 2.2")
  s.rubygems_version = "2.5.2.1"
  s.summary = "Run external commands on Unix or Windows"

  s.installed_by_version = "2.5.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<chefstyle>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<chefstyle>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<chefstyle>, [">= 0"])
  end
end
