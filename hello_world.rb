require 'rubygems'
require 'bundler/setup'
require 'sinatra'
# configure { set :server, :Puma }

get '/' do
  "Hello world, it's #{Time.now} at the server!"
end

get '/home' do
  name = "Anton"
  erb :index
end

post '/stats' do
    start = Time.now
    str = params[:fname].to_s
    # @kek = params[:fname]
    no_spaces = str.gsub(/\s+/, "")
    comma = str.count ','
    period = str.count '.'
    
    word_count = {} # empty hash for word count
    word_count.default = 0
    word_array = str.split
    word_array.each { |word| word_count[word] += 1} # count each word
    most_frequent = word_array.max_by {|word| word_array.count(word)}
    number_occurences = word_array.tally #this creates a hash
    highest_occurrence =  number_occurences[most_frequent]
     
     word_count = word_array.length()
     unique_words = word_array.uniq.length
     
    #"Size is #{str.size} and Length is #{str.length}"
    erb :stats, :locals => {:size => str.size, :size_small => no_spaces.size, :pages => (str.size/1800.0).round(3) , :comma => comma, :period => period, :most => most_frequent, :highest_occurrence => highest_occurrence, :start => start, :unique_words => unique_words, :word_count => word_count}
    #"My name is #{params[:fname]}, and I love #{params[:lname]}."
    #"The length is #{params[:fname]}.size"
end
