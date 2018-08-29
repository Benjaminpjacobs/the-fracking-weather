require 'rails_helper'

RSpec.describe SearchesController do
  describe "GET index" do
    it "renders the index view" do
      get :index
      expect(response.body).to match("The Fracking Weather")
      assert_select "form[action=\"/searches\"]" do
        assert_select "input[name=\"search[query]\"]"
      end
    end
  end

  describe "POST" do
    it "generates a new unique search" do
      VCR.use_cassette("geocode_unique") do
        expect(Search.count).to eq(0)
        
        post :create, params: {search: {query: "Denver"}}
        expect(Search.count).to eq(1)
      end
    end

    it "finds a search it has already done" do
      VCR.use_cassette("geocode_repeat") do
        s = Search.create(query: 'Denver')
        expect(Search.count).to eq(1)

        post :create, params: {search: {query: "Denver"}}
        expect(Search.count).to eq(1)
        expect(Search.first).to eq(s)
      end
    end

    it "finds a search within five miles of a search it has already done" do
      VCR.use_cassette("geocode_close") do
        s = Search.create(query: '80203')
        expect(Search.count).to eq(1)

        post :create, params: {search: {query: "80210"}}
        expect(Search.count).to eq(1)
        expect(Search.first).to eq(s)
      end
    end
    
    it "doesn't create a search if it cannot geocode" do
      VCR.use_cassette("geocode_fail") do
        expect(Search.count).to eq(0)
        post :create, params: {search: {query: "--"}}
        expect(Search.count).to eq(0)
      end
    end
  end
end