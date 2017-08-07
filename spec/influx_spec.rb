require "spec_helper"

RSpec.describe Influx do
  it "has a version number" do
    expect(Influx::VERSION).not_to be nil
  end
end
