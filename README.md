# The Fracking Weather

A copy of a glorious app and in homage to a glorious television saga. This app will tell you the fracking weather.

## Getting Started

Make sure to have Rails 5.2.1 and Ruby 2.4.1 installed.

### Running Locally

To run locally. 

* attempt to get an API Key from [WeatherUnderground](https://www.wunderground.com/)
* clone down the repo
* `bundle install`
* `rails db:setup`
* `touch .env`
* enter API key into `.env` file from above step into .env with key `WEATHER_API_KEY`
* don't forget to git ignore the .env file
* `rails server`

And now you can see the fracking weather LOCALLY!

## Running the tests

* `rake db:test:prepare` just in case
* `rspec`

## Deployment

This app is live. You can find out the fracking weather [RIGHT HERE](http://the-fracking-weather.herokuapp.com/)!

## Built With

* [Rails](https://api.rubyonrails.org/) - The web framework used
* [Geocoder](https://github.com/alexreisner/geocoder) - Used to geocode searches
* [WeatherUnderground](https://www.wunderground.com/) - Used for weather feeds
* [The Fucking Weather](http://thefuckingweather.com/) - Used for inspiration
* [Battlestar Galactica](https://en.wikipedia.org/wiki/Battlestar_Galactica_(2004_TV_series)) - Used for more inspiration

## Authors

* **Ben Jacobs** - *Initial work* - [Benjaminpjacobs](https://github.com/Benjaminpjacobs)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
