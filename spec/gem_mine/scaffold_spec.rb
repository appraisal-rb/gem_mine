# frozen_string_literal: true

require "tmpdir"

RSpec.describe GemMine::Scaffold do
  def path(value)
    Pathname(value)
  end

  def inside_tmp
    Dir.mktmpdir("gem-mine-spec") do |dir|
      yield Pathname(dir)
    end
  end

  it "creates a minimal gem scaffold" do
    inside_tmp do |dir|
      scaffold = described_class.new("dummy", root: dir.join("dummy"), version: "1.2.3").create

      expect(path(scaffold.gemspec_path)).to be_exist
      expect(path(scaffold.lib_path)).to be_exist
      expect(path(scaffold.built_gem_path)).not_to be_exist
      expect(path(scaffold.gemspec_path).read).to include('s.name    = "dummy"')
      expect(path(scaffold.gemspec_path).read).to include('s.homepage = "https://github.com/appraisal-rb/dummy"')
      expect(path(scaffold.lib_path).read).to eq("$dummy_version = \"1.2.3\"\n")
    end
  end

  it "builds and installs the scaffolded gem into a caller-controlled GEM_HOME" do
    inside_tmp do |dir|
      gem_home = dir.join("gems")
      scaffold = described_class.new("dummy", root: dir.join("dummy"), gem_home: gem_home).create

      scaffold.build.install

      expect(path(scaffold.built_gem_path)).to be_exist
      expect(gem_home.join("gems/dummy-1.0.0")).to be_directory
    end
  end

  it "creates the scaffold lazily before building" do
    inside_tmp do |dir|
      scaffold = described_class.new("lazy_build", root: dir.join("lazy_build"))

      scaffold.build

      expect(path(scaffold.gemspec_path)).to be_exist
      expect(path(scaffold.built_gem_path)).to be_exist
    end
  end

  it "builds the scaffold lazily before installing" do
    inside_tmp do |dir|
      gem_home = dir.join("gems")
      scaffold = described_class.new("lazy_install", root: dir.join("lazy_install"), gem_home: gem_home)

      scaffold.install

      expect(path(scaffold.built_gem_path)).to be_exist
      expect(gem_home.join("gems/lazy_install-1.0.0")).to be_directory
    end
  end

  it "initializes git scaffolds without requiring global signing config" do
    inside_tmp do |dir|
      scaffold = described_class.new("git_dummy", root: dir.join("git_dummy")).create

      scaffold.initialize_git

      expect(dir.join("git_dummy/.git")).to be_directory
      expect(`git -C #{Shellwords.escape(scaffold.root)} log --oneline`).to include("initial commit")
      expect(`git -C #{Shellwords.escape(scaffold.root)} config user.email`).to eq("gem_mine@appraisal-rb.local\n")
      expect(`git -C #{Shellwords.escape(scaffold.root)} config user.name`).to eq("GemMine\n")
    end
  end

  it "creates the scaffold lazily before initializing git" do
    inside_tmp do |dir|
      scaffold = described_class.new("lazy_git", root: dir.join("lazy_git"))

      scaffold.initialize_git

      expect(path(scaffold.gemspec_path)).to be_exist
      expect(dir.join("lazy_git/.git")).to be_directory
    end
  end

  it "cleans scaffold roots" do
    inside_tmp do |dir|
      scaffold = described_class.new("dummy", root: dir.join("dummy")).create

      scaffold.clean

      expect(path(scaffold.root)).not_to be_exist
    end
  end

  it "raises command errors with captured output" do
    inside_tmp do |dir|
      scaffold = described_class.new("broken", root: dir.join("broken")).create

      expect do
        scaffold.__send__(:run, "ruby", "-e", "warn 'nope'; exit 7", chdir: scaffold.root)
      end.to raise_error(GemMine::CommandError) { |error|
        expect(error.command).to eq(["ruby", "-e", "warn 'nope'; exit 7"])
        expect(error.status.exitstatus).to eq(7)
        expect(error.stderr).to include("nope")
      }
    end
  end

  it "does not set GEM_HOME when no gem home is configured" do
    inside_tmp do |dir|
      scaffold = described_class.new("env_dummy", root: dir.join("env_dummy")).create

      expect(scaffold.__send__(:gem_home_env)).to eq({})
    end
  end

  it "logs commands in verbose mode" do
    inside_tmp do |dir|
      scaffold = described_class.new("verbose_dummy", root: dir.join("verbose_dummy"), verbose: true).create

      expect do
        scaffold.__send__(:run, "ruby", "-e", "exit", chdir: scaffold.root)
      end.to output(/gem_mine:/).to_stderr
    end
  end
end
