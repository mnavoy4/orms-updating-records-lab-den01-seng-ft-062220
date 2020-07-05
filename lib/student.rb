require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize id=nil, name, grade
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists students (
        id integer primary key,
        name text,
        grade text
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      drop table if exists students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        insert into students (name, grade) values (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
    end
  end

  def self.create name, grade
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db row
    student = self.new(row[0], row[1], row[2])
    student
  end

  def self.find_by_name name
    sql = <<-SQL
      select * from students where students.name = ? limit 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      update students set name = ?, grade = ? where id = ?
    SQL
    DB[:conn].execute(sql, name, grade, id)
  end

end
