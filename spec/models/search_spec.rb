require 'rails_helper'

RSpec.describe Search, type: :model do
  it { should validate_presence_of(:query) }

  it "geocodes search based on query" do
    s = Search.create!(query: "Denver, CO")
    expect(s).to be_valid
    expect(s.latitude).to be_present
    expect(s.longitude).to be_present
    expect(s.city).to match("Denver")
    expect(s.state).to match("Colorado")
    expect(s.country).to match("USA")
    expect(s.zipcode).to match("80203")
  end

  it "stores and counts previous searches" do
    t = Time.now
    s = Search.create!(query: "Denver, CO")
    expect(s.count).to eq(0)
    s.previous << t
    s.save
    expect(s.count).to eq(1)
    expect(s.previous.first).to match(t.to_s)
  end
end