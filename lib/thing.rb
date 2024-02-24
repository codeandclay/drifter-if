class Thing
  attr_accessor :id, :contains

  def initialize(id, **args)
    @id = id
    @contains = args[:contains]
  end
end

# Place items in dummy game
game = {
  great_hall: [
    :ball,
    :table,
    { box: [:gem] },
    { cupboard: [
      { box: [:gem] },
      { box: [:gem] },
      { cupboard: [
        { box: [:gem] },
        { box: [:gem] }
      ] }
    ] }
  ]
}

def game_map(game)
  game.map do |key, value|
    Thing.new(
      key,
      contains: value.map do |thing|
        next populated_game(thing) if thing.instance_of?(Hash)

        Thing.new(thing)
      end
    )
  end
end
