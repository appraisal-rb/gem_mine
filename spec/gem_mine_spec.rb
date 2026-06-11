# frozen_string_literal: true

RSpec.describe GemMine do
  it "has a version number" do
    expect(GemMine::VERSION).not_to be_nil
  end

  it "exposes its version through version_gem" do
    expect(GemMine::Version).to respond_to(:to_h)
  end
end
