# frozen_string_literal: true

RSpec.describe GemMine do
  it "has a version number" do
    expect(GemMine::VERSION).not_to be_nil
  end

  it "exposes its version through version_gem" do
    expect(GemMine::Version).to respond_to(:to_h)
  end

  it "creates scaffolded gems through the module helper" do
    Dir.mktmpdir("gem-mine-helper") do |dir|
      scaffold = described_class.scaffold("helper_dummy", root: File.join(dir, "helper_dummy"), build: false)

      expect(Pathname(scaffold.gemspec_path)).to be_exist
      expect(Pathname(scaffold.built_gem_path)).not_to be_exist
    end
  end

  it "builds, installs, and git-initializes through the module helper" do
    Dir.mktmpdir("gem-mine-helper-full") do |dir|
      scaffold = described_class.scaffold(
        "helper_full",
        root: File.join(dir, "helper_full"),
        gem_home: File.join(dir, "gems"),
        git: true
      )

      expect(Pathname(scaffold.built_gem_path)).to be_exist
      expect(Pathname(File.join(dir, "gems/gems/helper_full-1.0.0"))).to be_directory
      expect(Pathname(File.join(scaffold.root, ".git"))).to be_directory
    end
  end

  it "cleans paths through the module helper" do
    Dir.mktmpdir("gem-mine-clean") do |dir|
      path = File.join(dir, "gone")
      FileUtils.mkdir_p(path)

      described_class.clean(path)

      expect(Pathname(path)).not_to be_exist
    end
  end
end
