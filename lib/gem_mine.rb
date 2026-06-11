# frozen_string_literal: true

require "version_gem"

require "fileutils"
require "open3"
require "shellwords"

require_relative "gem_mine/version"

module GemMine
  class Error < StandardError; end

  class CommandError < Error
    attr_reader :command, :status, :stdout, :stderr

    def initialize(command, status, stdout, stderr)
      @command = command
      @status = status
      @stdout = stdout
      @stderr = stderr
      super("Command failed (#{status.exitstatus}): #{command.join(" ")}")
    end
  end

  class Scaffold
    DEFAULT_AUTHOR = "Mr. Smith"
    DEFAULT_HOMEPAGE_BASE = "http://github.com/thoughtbot"
    DEFAULT_LICENSE = "MIT"
    DEFAULT_REQUIRED_RUBY_VERSION = ">= 1.8.7"
    DEFAULT_SUMMARY = "summary"
    DEFAULT_VERSION = "1.0.0"

    attr_reader :name,
      :version,
      :root,
      :gem_home,
      :author,
      :summary,
      :license,
      :homepage,
      :required_ruby_version

    def initialize(
      name,
      root:,
      version: DEFAULT_VERSION,
      gem_home: nil,
      author: DEFAULT_AUTHOR,
      summary: DEFAULT_SUMMARY,
      license: DEFAULT_LICENSE,
      homepage: nil,
      required_ruby_version: DEFAULT_REQUIRED_RUBY_VERSION,
      verbose: false
    )
      @name = name.to_s
      @version = version.to_s
      @root = File.expand_path(root)
      @gem_home = gem_home && File.expand_path(gem_home)
      @author = author
      @summary = summary
      @license = license
      @homepage = homepage || "#{DEFAULT_HOMEPAGE_BASE}/#{@name}"
      @required_ruby_version = required_ruby_version
      @verbose = verbose
    end

    def create
      FileUtils.mkdir_p(lib_dir)
      write_gemspec
      write_lib_file
      self
    end

    def build
      create unless File.file?(gemspec_path)
      run("gem", "build", gemspec_file, chdir: root)
      self
    end

    def install
      build unless File.file?(built_gem_path)
      run("gem", "install", "-lN", built_gem_file, "-v", version, chdir: root, env: gem_home_env)
      self
    end

    def initialize_git
      create unless File.file?(gemspec_path)
      run("git", "init", ".", "--initial-branch=main", chdir: root)
      run("git", "config", "user.email", "appraisal@thoughtbot.com", chdir: root)
      run("git", "config", "user.name", "Appraisal", chdir: root)
      run("git", "add", ".", chdir: root)
      run("git", "commit", "--all", "--no-verify", "--message", "initial commit", chdir: root)
      self
    end

    def clean
      FileUtils.rm_rf(root)
      self
    end

    def lib_file
      File.join("lib", "#{name}.rb")
    end

    def lib_path
      File.join(root, lib_file)
    end

    def gemspec_file
      "#{name}.gemspec"
    end

    def gemspec_path
      File.join(root, gemspec_file)
    end

    def built_gem_file
      "#{name}-#{version}.gem"
    end

    def built_gem_path
      File.join(root, built_gem_file)
    end

    private

    def gem_home_env
      return {} unless gem_home

      {"GEM_HOME" => gem_home}
    end

    def lib_dir
      File.dirname(lib_path)
    end

    def write_gemspec
      File.write(gemspec_path, <<~GEMSPEC)
        Gem::Specification.new do |s|
          s.name    = #{name.inspect}
          s.version = #{version.inspect}
          s.authors = #{author.inspect}
          s.summary = #{summary.inspect}
          s.files   = #{lib_file.inspect}
          s.license = #{license.inspect}
          s.homepage = #{homepage.inspect}
          s.required_ruby_version = #{required_ruby_version.inspect}
        end
      GEMSPEC
    end

    def write_lib_file
      File.write(lib_path, "$#{name}_version = #{version.inspect}\n")
    end

    def run(*command, chdir:, env: {})
      warn_command(command, chdir)
      stdout, stderr, status = Open3.capture3(env, *command, chdir: chdir)
      return stdout if status.success?

      raise CommandError.new(command, status, stdout, stderr)
    end

    def warn_command(command, chdir)
      return unless @verbose

      warn "gem_mine: (#{chdir}) #{command.shelljoin}"
    end
  end

  def self.scaffold(name, root:, **options)
    build = options.delete(:build) { true }
    install = options.delete(:install) { build }
    git = options.delete(:git) { false }

    Scaffold.new(name, root: root, **options).tap do |scaffold|
      scaffold.create
      scaffold.initialize_git if git
      scaffold.build if build
      scaffold.install if install
    end
  end

  def self.clean(path)
    FileUtils.rm_rf(path)
  end
end

GemMine::Version.class_eval do
  extend VersionGem::Basic
end
