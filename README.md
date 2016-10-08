# Objectmancy

Objectmancy is a way to convert Hashes to Objects of your choosing without having to inherit from anything, primitive or otherwise. You need only include the appropriate module and define your attributes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'objectmancy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install objectmancy

## Usage

### Objectable

`Objectmancy::Objectable` is the Module to mixin in order to consume the abilities. It works with the cooperation of two methos `.attribute` and `.initialize`. `Objectable` provides an `.initialize` method for your object that you can use at any time. You may override with your own and call `super` and pass it your values to create your object. You may also define a separate class method to use with `Objectable`. However, preferably, you will keep and use `Objectable`'s `.initialize` method and make use of the `before_initialize` or `after_initialize` callbacks if you need custom behavior.

The following is an extensive example of a set of classes built to consume `Objectmancy::Objectable` in all of its basic ways. This is taken from the tests, with comments added as guidance. Note that the `#==` definition is not required; I added it for tests. A future enhancement is to implement `#==` for consumers. Skipping ahead to the `TestObject` definition will provide the most value.

```ruby
class Book
  include Objectmancy::Objectable

  # These are basic attributes. They can be anything; your new object
  # will have these attributes set to whatever key this is in the Hash.
  attribute :title
  attribute :author

  def ==(other)
    self.class == other.class &&
      title == other.title &&
      author == other.author
  end
end

class Cat
  attr_reader :name

  # Just to notice that you could create anything, not necessarily what the 
  # key explicitly is.
  def initialize(name)
    @name = name
  end

  def ==(other)
    self.class == other.class &&
      name == other.name
  end
end

class Game
  attr_reader :title, :developer

  def initialize(title, developer)
    @title = title
    @developer = developer
  end

  # An arbitrary method defined to create this object from something other
  # than new. Since 
  def self.from_string(str)
    values = str.split '/'
    new(values.first, values.last)
  end

  def ==(other)
    self.class == other.class &&
      title == other.title &&
      developer == other.developer
  end
end

class TestObject
  include Objectmancy::Objectable

  attribute :name

  attribute :update_date, type: :datetime
  attribute :book, type: Book
  attribute :pet, type: Cat
  attribute :video_game, type: Game, objectable: :from_string
  attribute :primes

  multiples :birth_dates, type: :datetime
  multiples :library, type: Book
  multiples :menagerie, type: Cat
  multiples :board_games, type: Game, objectable: :from_string
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/objectmancy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

