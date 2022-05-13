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

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"

    @db.exec_params(statement, params)
  end

  def disconnect
    @db.close
  end

  def create_reminder(task, date, agency)
    sql = <<~SQL
                INSERT INTO reminders (task_name, due_date, agency)
                VALUES ($1, $2, $3)
            SQL

    query(sql, task, date, agency)
  end

  def all_reminders # display all reminders
    sql = "SELECT * FROM reminders"
    result = query(sql)
    x = result.map do |tuple|
      { id: tuple["id"],
        task_name: tuple["task_name"],
        due_date: tuple["due_date"],
        agency: tuple["agency"]
      }
    end
    # binding.pry
  end

  def delete_reminder(id)
    sql = "DELETE FROM reminders WHERE id = $1"
    query(sql, id)
  end
end

# <% @reminders.each do |hash| %>
#   <tr>
#     <td><%= "#{hash[:task_name]}" %></td>
#     <td><%= "#{hash[:agency].capitalize}" %></td>
#     <td><%= "#{hash[:due_date]}" %></td>
#     <td>
#       <form action="/delete/<%= idx %>" method="post" class="delete">
#         <input type="submit" value="Delete">
#       </form>
#     </td>
#   </tr>
#   <% end %>

#   <% session[:reminders].each_with_index do |hash, idx| %>
#     <tr>
#       <td><%= "#{hash[:task]}" %></td>
#       <td><%= "#{hash[:agency].capitalize}" %></td>
#       <td><%= "#{hash[:month]}/#{hash[:day]}" %></td>
#       <td>
#         <form action="/delete/<%= idx %>" method="post" class="delete">
#           <input type="submit" value="Delete">
#         </form>
#       </td>
#     </tr>
#     <% end %>