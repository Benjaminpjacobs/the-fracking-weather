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
end