require "sinatra"
require "pry"
require_relative "db_persistence"

=begin
TODO:
# - set up DatabasePersistence class (require pg, database connection, etc)
# - extract database code to separate class
# - format Due Date column to just show month and day
# - fix the sort and delete buttons
# - make example table and redo example page to use sql
# - fix agency_count method
# - fix sign in / sign out situation - create one user for the app?

- sort reminders by date, agency, task name
- add a complete button that you can check and uncheck
- sort by complete / incomplete
=end

configure do
  enable :sessions
  set :session_secret, 'secret'
  # set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "db_persistence.rb"
end

# before do
#   session[:reminders] ||= []
# end

before do
  @storage = DatabasePersistence.new(logger)
  session[:signed_in] ||= false
end

after do
  @storage.disconnect
end

helpers do
  def agency_count #todo = do with SQL
    result = @storage.count_agency

    federal = 0
    state = 0
    local = 0

    result.each do |tuple|
      if tuple[:agency] == "local"
        local = tuple[:count]
      elsif tuple[:agency] == "federal"
        federal = tuple[:count]
      elsif tuple[:agency] == "state"
        state = tuple[:count]
      end
    end

    if result.size == 1
      "You have #{result.size} reminder... #{federal} Federal, #{state} State and #{local} Local."
    else
      "You have #{result.size} reminders... #{federal} Federal, #{state} State and #{local} Local."
    end
  end
end

get "/" do
  erb :home
end

def valid_login?(username, password) #todo = validate user from db?
  (username == session[:username]) && (password == session[:password]) ? true : false
end

# log in to account
post "/signin" do
  if valid_login?(params[:username].to_s, params[:password].to_s)
    session[:signed_in] = true
    redirect "/view"
  else
    session[:error] = "That is not the correct username or password"
    redirect "/"
  end
end

# sign up page
get "/signup" do
  erb :signup
end

def error_for_sign_up(username, password)
  if username.size < 5
    "Username should be at least 5 characters"
  elsif password.size < 5
    "Password should be at least 5 characters"
  end
end

# create new account
post "/signup/go" do
  error = error_for_sign_up(params[:username], params[:password])

  if error
    session[:error] = error
    erb :signup
  else
    session[:username] = params[:username].to_s
    session[:password] = params[:password].to_s
    session[:signed_in] = true

    session[:message] = "Success! You have created a new account."
    redirect "/view"
  end
end

# log out of account
post "/signout" do
  session[:signed_in] = false
  session[:message] = "You have been signed out."

  redirect "/"
end

# view reminders
get "/view" do
  # @reminders = session[:reminders]

  if session[:signed_in] == false
    session[:error] = "You must be signed in to view this page."
    redirect "/"
  else
    @reminders = @storage.all_reminders
    erb :view
  end

end

def error_for_inputs(task)
  if task.size >= 30
    "Task should be less than 30 characters"
  end
end

post "/view/add" do
  # if valid_input?(params[:task], params[:day], params[:month], params[:agency])
  task = params[:task]
  date = params[:date]
  agency = params[:agency]
  error = error_for_inputs(params[:task])
  if error
    session[:error] = error
    # erb :view
  else
    @storage.create_reminder(task, date, agency)
    # session[:reminders] << {task: params[:task], day: params[:day], month: params[:month], agency: params[:agency]}
    session[:message] = "Success! Reminder was added."
  end

  redirect "/view"
end

post "/reset" do # reset password
  session.delete(:username)
  session.delete(:password)
  redirect "/"
end

post "/delete/all" do
  # session[:reminders].delete_if {|hash| hash.empty? == false }
  @storage.delete_all
  session[:message] = "All reminders deleted."
  redirect "/view"
end

post "/delete/:id" do
  # idx = params[:idx].to_i
  # session[:reminders].delete_at(idx)
  id = params[:id].to_i
  @storage.delete_reminder(id)
  session[:message] = "Reminder successfully deleted."
  redirect "/view"
end

get "/sort" do
  # session[:reminders].sort! {|a, b| a[:month].to_i <=> b[:month].to_i}
  # @storage.sort_by_month

  @reminders = @storage.sort_by_month

  # @storage.all_reminders.sort! {|a, b| a[:due_date].to_i <=> b[:due_date].to_i }
  # @storage.all_reminders(2)
  # p @storage.all_reminders
  # session[:sorter] = "month"
  redirect "/view"
end

get "/example" do
  @example = @storage.list_example

  erb :example
end

# SORT FORM:
# <form action="/sort" method="get" class="sorter">
#   <label for="sort">Sort reminders by month due =></label>
#   <input type="submit" value="Sort by month">
# </form>

# <% session[:reminders].each do |hash| %>
#   <p><%= "[#{hash[:agency]}] - #{hash[:task]} is due on #{hash[:month]} #{hash[:day]}" %> <p>
# <% end %>

  # @example = [
  #   {task: "File Q4 Sales Tax", month: 1, day: 1, agency: "State"},
  #   {task: "File Corporate Tax Return", day: 15, month: 3, agency: "Federal"},
  #   {task: "File Q1 Sales Tax", month: 4, day: 1, agency: "State"},
  #   {task: "File Personal Tax Return", day: 15, month: 4, agency: "Federal"},
  #   {task: "Renew City Business Tax", day: 1, month: 6, agency: "Local"},
  #   {task: "File Q2 Sales Tax", month: 7, day: 1, agency: "State"},
  #   {task: "File Q3 Sales Tax", month: 10, day: 1, agency: "State"},
  # ]