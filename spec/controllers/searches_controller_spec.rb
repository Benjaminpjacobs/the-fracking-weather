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

  describe "GET previous_searches" do
    it "retrieves previous searches partial sorted" do
      VCR.use_cassette("previous_searches") do
        one_hour_ago = 1.hour.ago
        two_hours_ago = 2.hour.ago
        three_hours_ago = 2.hour.ago
        post :create, params: {search: {query: "Denver, CO"}}
        s1 = Search.find_by(query: "Denver, CO")
        s1.update_columns previous: [one_hour_ago.to_s,two_hours_ago.to_s]
        post :create, params: {search: {query: "San Diego, CA"}}
        s2 = Search.find_by(query: "San Diego, CA")
        s2.update_columns previous: [one_hour_ago.to_s, two_hours_ago.to_s, three_hours_ago.to_s]
        post :create, params: {search: {query: "Boston, MA"}}
        s3 = Search.find_by(query: "Boston, MA")
        s3.update_columns previous: [one_hour_ago.to_s]
        get :previous_searches, params: {sort_by: "count", sort_direction: "desc"}
        
        assert_select "#searches" do
          assert_select "div:nth-child(1)" do
            assert_select "#link_search_#{s2.id}", "San Diego, CA"
          end
          assert_select "div:nth-child(2)" do
            assert_select "#link_search_#{s1.id}", "Denver, CO"
          end
          assert_select "div:nth-child(3)" do
            assert_select "#link_search_#{s3.id}", "Boston, MA"
          end
        end

        get :previous_searches, params: {sort_by: "count", sort_direction: "asc"}
        assert_select "#searches" do
          assert_select "div:nth-child(1)" do
            assert_select "#link_search_#{s3.id}", "Boston, MA"
          end
          assert_select "div:nth-child(2)" do
            assert_select "#link_search_#{s1.id}", "Denver, CO"
          end
          assert_select "div:nth-child(3)" do
            assert_select "#link_search_#{s2.id}", "San Diego, CA"
          end
        end
        
        get :previous_searches, params: {sort_by: "query", sort_direction: "desc"}

        assert_select "#searches" do
          assert_select "div:nth-child(1)" do
            assert_select "#link_search_#{s2.id}", "San Diego, CA"
          end
          assert_select "div:nth-child(2)" do
            assert_select "#link_search_#{s1.id}", "Denver, CO"
          end
          assert_select "div:nth-child(3)" do
            assert_select "#link_search_#{s3.id}", "Boston, MA"
          end
        end
      end
    end
  end
  
  describe "GET show" do
    it "renders the show view as if searched" do
      VCR.use_cassette("previous_searches") do
        one_hour_ago = 1.hour.ago
        two_hours_ago = 2.hour.ago
        three_hours_ago = 2.hour.ago
        post :create, params: {search: {query: "Denver, CO"}}
        s1 = Search.find_by(query: "Denver, CO")
        s1.update_columns previous: [one_hour_ago.to_s,two_hours_ago.to_s]
        post :create, params: {search: {query: "San Diego, CA"}}
        s2 = Search.find_by(query: "San Diego, CA")
        s2.update_columns previous: [one_hour_ago.to_s, two_hours_ago.to_s, three_hours_ago.to_s]
        post :create, params: {search: {query: "Boston, MA"}}
        s3 = Search.find_by(query: "Boston, MA")
        s3.update_columns previous: [one_hour_ago.to_s]
        get :show, params: {id: s3.id}

        expect(response.body).to match(s3.cached_weather['current_observation']['temp_f'].to_s)
        expect(response.body).to match(s3.cached_weather['current_observation']['weather'])
        expect(response.body).to match(s3.cached_weather['current_observation']['display_location']['full'])

        assert_select "div.times" do
          expect(response.body).to match(one_hour_ago.strftime("%I:%M %p"))
          expect(response.body).to match(one_hour_ago.strftime("%m/%d/%y"))
        end

        assert_select "#search_#{s1.id}" do
          assert_select "#link_search_#{s1.id}", "Denver, CO"
        end
        assert_select "#search_#{s2.id}" do
          assert_select "#link_search_#{s2.id}", "San Diego, CA"
        end
        assert_select "#search_#{s3.id}" do
          assert_select "#link_search_#{s3.id}", "Boston, MA"
        end
      end
    end
  end
  
  describe "POST create" do
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
        expect(response.body).to match("Fracking Try Again!")
      end
    end

    it "responds with error if no query" do
      post :create, params: {search: {query: ""}}
      expect(response.body).to match("You Gotta Fracking Ask Me Something!")
    end

    it "retrieves weather from search if not cached" do
      VCR.use_cassette("weather") do
        post :create, params: {search: {query: "Denver"}}
        search = Search.last
        expect(response.body).to match(search.cached_weather['current_observation']['temp_f'].to_s)
        expect(response.body).to match(search.cached_weather['current_observation']['weather'])
        expect(response.body).to match("#{search.city}, #{search.state}")
      end
    end
    
    it "retrieves weather from cache if cached weather" do
      VCR.use_cassette("geocode_repeat") do
        s = Search.create(query: 'Denver')
        s.update(cached_weather: {current_observation: {temp_f: 100.0, weather: "Sunny", display_location: {full: "Somewhere"}}})

        post :create, params: {search: {query: "Denver"}}
        search = Search.last
        expect(HTTParty).to_not receive(:get)
        expect(response.body).to match(search.cached_weather['current_observation']['temp_f'].to_s)
        expect(response.body).to match(search.cached_weather['current_observation']['weather'])
        expect(response.body).to match("#{search.city}, #{search.state}")
      end
    end
      
    it "displays times of previous query searches" do
      VCR.use_cassette("previous_queries") do
        s = Search.create(query: 'Denver')
        s.update(cached_weather: {current_observation: {temp_f: 100.0, weather: "Sunny", display_location: {full: "Somewhere"}}})
        one_hour_ago = 1.hour.ago
        two_hours_ago = 2.hour.ago
        s.previous << one_hour_ago.to_s
        s.previous << two_hours_ago.to_s
        s.save

        post :create, params: {search: {query: "Denver"}}
        search = Search.last
        assert_select "div.times" do
          expect(response.body).to match(one_hour_ago.strftime("%I:%M %p"))
          expect(response.body).to match(one_hour_ago.strftime("%m/%d/%y"))
          expect(response.body).to match(two_hours_ago.strftime("%I:%M %p"))
          expect(response.body).to match(two_hours_ago.strftime("%m/%d/%y"))
        end
      end
    end

    it "displays times of previous query searches" do
      VCR.use_cassette("previous_searches") do
        one_hour_ago = 1.hour.ago
        two_hours_ago = 2.hour.ago
        three_hours_ago = 2.hour.ago
        post :create, params: {search: {query: "Denver, CO"}}
        s1 = Search.find_by(query: "Denver, CO")
        s1.update_columns previous: [one_hour_ago.to_s,two_hours_ago.to_s]
        post :create, params: {search: {query: "San Diego, CA"}}
        s2 = Search.find_by(query: "San Diego, CA")
        s2.update_columns previous: [one_hour_ago.to_s, two_hours_ago.to_s, three_hours_ago.to_s]
        post :create, params: {search: {query: "Boston, MA"}}
        s3 = Search.find_by(query: "Boston, MA")
        s3.update_columns previous: [one_hour_ago.to_s]
        post :create, params: {search: {query: "Boston, MA"}}

        search = Search.last
        assert_select "#search_#{s1.id}" do
          assert_select "#count_search_#{s1.id}", '2'
          assert_select "#link_search_#{s1.id}", "Denver, CO"
        end
        assert_select "#search_#{s2.id}" do
          assert_select "#count_search_#{s2.id}", '3'
          assert_select "#link_search_#{s2.id}", "San Diego, CA"
        end
        assert_select "#search_#{s3.id}" do
          assert_select "#count_search_#{s3.id}", '2'
          assert_select "#link_search_#{s3.id}", "Boston, MA"
        end
      end
    end
  end
end