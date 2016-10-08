$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'objectmancy'

require 'minitest/autorun'
require 'minitest/pride'

# Setup test classes
module ObjTestClasses
  class Book
    include Objectmancy::Objectable

    attribute :title
    attribute :author
  end

  class Cat
    attr_reader :name

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

    attr_reader :before_init, :after_init

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

    def before_initialize
      @before_init = :before_set
    end

    def after_initialize
      @after_init = :after_set
    end
  end
end
