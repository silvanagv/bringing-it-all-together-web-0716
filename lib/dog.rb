class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)

    sql = <<-SQL
    SELECT id FROM dogs
    WHERE name = ?
    SQL
    self.id = DB[:conn].execute(sql, name)[0][0]
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    raw = DB[:conn].execute(sql, id)
    hash = {id: raw[0][0], name: raw[0][1], breed: raw[0][2]}

    dog = Dog.new(hash)
    dog.id = raw[0][0]
    dog
  end

  def self.find_or_create_by(hash)
    if hash[:id]
      binding.pry
      sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
      result = DB[:conn].execute(sql, hash[:id])
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, hash[:name], hash[:breed])

      sql = <<-SQL
      SELECT id FROM dogs
      WHERE name = ?
      AND breed = ?
      SQL
      dog = Dog.new(hash)
      dog.id = DB[:conn].execute(sql, hash[:name], hash[:breed])[0][0]
      result = dog
    end
    result
  end

  def self.new_from_db(array)
    hash = {name: array[1], breed: array[2]}
    dog = Dog.new(hash)
    dog.id = array[0]
    dog
  end


  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    raw = DB[:conn].execute(sql, name)
    hash = {id: raw[0][0], name: raw[0][1], breed: raw[0][2]}

    dog = Dog.new(hash)
    dog.id = raw[0][0]
    dog
  end

  def update
    self
    sql = <<-SQL
    UPDATE dogs
    SET name=?, breed=?
    WHERE id=?
    SQL
    stuff = DB[:conn].execute(sql, name, breed, id)
  end
end
