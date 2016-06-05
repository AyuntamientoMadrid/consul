require 'rails_helper'

describe Statement do
  let(:statement) { build(:statement) }

  it "should be valid" do
    expect(statement).to be_valid
  end

  it "should not be valid without an attachment" do
    statement.attachment = nil
    expect(statement).to_not be_valid
  end

  it "should not be valid without an associated audit" do
    statement.audit = nil
    expect(statement).to_not be_valid
  end
end
