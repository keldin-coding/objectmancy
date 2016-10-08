# Objectmancy

![](https://travis-ci.org/jon2992/objectmancy.svg?branch=master)

Objectmancy is a way to convert Hashes to Objects of your choosing without having to inherit from anything, primitive or otherwise. You need only include the appropriate module and define your attributes.

## Table of Contents
- [Installation](#installation)
    - [Usage](#usage)
        - [Objectable](#objectable)
            - [.initialize](#initialize)
            - [.attribute](#attribute)
            - [.multiples](#multiples)
            - [Supported types](#supported-types)
            - [Example](#example)
    - [Development](#development)
    - [Contributing](#contributing)
    - [License](#license)

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

`Objectmancy::Objectable` is the Module to mixin in order to consume the abilities. It works with the cooperation of three methods `.attribute`, `.multiples` and `.initialize`. 

#### `.initialize`
`Objectable` provides an `.initialize` method for your object that you can use at any time. You may override with your own and call `super` and pass it your values to create your object. You may also define a separate class method to use with `Objectable`. However, preferably, you will keep and use `Objectable`'s `.initialize` method and make use of the `before_initialize` or `after_initialize` callbacks if you need custom behavior.

#### `.attribute`
By default, your new object's values will be set to whatever the associated key is in the base hash. You can specify a `:type` option which lets you use either a Class of your choosing to create the object, or a Symbol representing a type that `Objectmancy` knows about. By default, `Objectable` will call `new` on your passed in type and pass the value of the hash to it. You may set the `:objectable` option to provide a different method to call on the `:type` value. The value of the hash is still the only argument passed.

#### `.multiples`
`multiples` behaves in much the same way, except a `:type` option is required. `.multiples` is intended for Arrays of objects which need special attention (i.e., custom defined types or objects of a type supported by `Objectmancy`)

#### Supported types

Currently supported known types with built-in parsing into non-standard objects:
* `:datetime` - uses the [`ISO8601` gem](https://github.com/arnau/ISO8601) for parsing

#### Example

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
  # than new. This allows you to avoid the "shimming" if you prefer, and makes 
  # it possible to override initialize and still use Objectable, providing 
  # some from of backwards compatibility.
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

  # Random attr_reader used to test that the callbacks were in fact invoked.
  attr_reader :before_init, :after_init

  attribute :name

  # Usage of a supported, built-in type
  attribute :update_date, type: :datetime

  # Usage of a user-defined type using Objectable
  attribute :book, type: Book

  # Usage of a user-defined type with new method 
  attribute :pet, type: Cat

  # USage of a user-defined type with a custom objectable method
  attribute :video_game, type: Game, objectable: :from_string

  # Basic array of integers
  attribute :primes

  # Array of objects to be parsed into a supported type
  multiples :birth_dates, type: :datetime

  # Array of objects into a user-defined type using Objectable
  multiples :library, type: Book

  # Array of objects into a user-defined type using new
  multiples :menagerie, type: Cat

  # Array of objects into a user-defined type using a custom objectable method
  multiples :board_games, type: Game, objectable: :from_string

  # Callback method used at the beginning of the Objectable.initialize method. 
  # This is called before any attributes are set.
  def before_initialize
    @before_init = :before_set
  end

  # Callback method used at the end of the Objectable.initialize method.
  # This is called after all attributes are set.
  def after_initialize
    @after_init = :after_set
  end
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake test` to run the tests. You can run `bundle exec rubocop` to run the [rubocop](https://github.com/bbatsov/rubocop) static analysis tool.

To install this gem onto your local machine, run `bundle exec rake install`, or you can use `bundle exec pry`, as I've included `pry` in the Gemfile. Please feel free to comment this out if you prefer a different debugger.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/objectmancy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

