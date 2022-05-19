require "pg"
require "pry"

class DatabasePersistence
  def initialize(logger)
    # @db = PG.connect(dbname: "reminders")

    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: "reminders")
    end

    @logger = logger
  end

  def disconnect
    @db.close
  end

  def list_example
    sql = "SELECT * FROM example"
    result = query(sql)

    create_hash(result)
  end

  def count_agency
    sql = "SELECT agency, COUNT(agency) FROM reminders GROUP BY agency;"
    result = query(sql)
    result.map do |tuple|
      { agency: tuple["agency"],
        count: tuple["count"]
    }
    end
  end

  def create_reminder(task, date, agency)
    sql = <<~SQL
                INSERT INTO reminders (task_name, due_date, agency)
                VALUES ($1, $2, $3)
            SQL

    query(sql, task, date, agency)
  end

  def all_reminders # display all reminders
    # if @@sorter == "month"
    sql = "SELECT * FROM reminders ORDER BY due_date"
    # elsif
      # sql = "SELECT * FROM reminders"
    # end

    result = query(sql)

    create_hash(result)
    end
  end

  def delete_reminder(id)
    sql = "DELETE FROM reminders WHERE id = $1"
    query(sql, id)
  end

  def delete_all
    query("DELETE FROM reminders")
  end

  private

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"

    @db.exec_params(statement, params)
  end

  def create_hash(result)
    result.map do |tuple|
      { id: tuple["id"],
        task_name: tuple["task_name"],
        due_date: tuple["due_date"],
        agency: tuple["agency"]
      }
  end

end