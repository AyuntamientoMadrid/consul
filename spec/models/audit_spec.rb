require 'rails_helper'

describe Audit do
  let(:audit) { build(:audit) }

  it "should be valid" do
    expect(audit).to be_valid
  end

  it "should not be valid without an name" do
    audit.name = nil
    expect(audit).to_not be_valid
  end
end
