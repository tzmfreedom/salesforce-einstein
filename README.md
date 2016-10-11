# Metamind

[![Build Status](https://travis-ci.org/tzmfreedom/metamind-ruby.svg?branch=master)](https://travis-ci.org/tzmfreedom/metamind-ruby)

API Client for Salesforce MetaMind(http://metamind.io)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metamind'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metamind

## Usage

- Initialize Client
```ruby
client = Metamind::Client.new(cert: '/path/to/certificate', 
                              password: 'certificate password', 
                              email: 'metamind account email')
```
or
```ruby
client = Metamind::Client.new(private_key: '/path/to/private_key', 
                              password: 'private_key password', 
                              email: 'metamind account email')
```

- Prediction with Image URL
```ruby
client.predict_with_url 'url', 'modelId'
```

- Prediction with Image Base64 String
```ruby
client.predict_with_base64 'base64 string', 'modelId'
```

- Create a Dataset
```ruby
client.create_dataset 'name', 'labels'
```

- Get a Dataset
```ruby
client.get_dataset 'dataset_id'
```

- Get All Datasets
```ruby
client.get_all_datasets
```

- Delete a Dataset
```ruby
client.delete_dataset 'dataset_id'
```

- Create a Label
```ruby
client.create_label 'dataset_id', 'name'
```

- Get a Label
```ruby
client.get_label 'dataset_id', 'label_id'
```

- Create an Example
```ruby
client.create_example 'dataset_id', params
```

- Get an Example
```ruby
client.get_example 'dataset_id', 'example_id'
```

- Get All Examples
```ruby
client.get_all_example 'dataset_id'
```

- Delete an Example
```ruby
client.delete_example 'dataset_id', 'example_id'
```

- Train a Dataset
```ruby
client.train_dataset params
```

- Get Training Status
```ruby
client.get_training_status 'model_id'
```

- Get Model Metrics
```ruby
client.get_model_metrics 'model_id'
```

- Get All Models
```ruby
client.get_all_models 'dataset_id'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tzmfreedom/metamind.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

