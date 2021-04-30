require 'rubygems'
require 'bundler/setup'
require 'sinatra'
# configure { set :server, :Puma }
require 'i18n'
enable :sessions

I18n.load_path << Dir[File.expand_path("locales") + "/*.yml"]
I18n.default_locale = :en

get '/' do
  redirect to('/home')
end

get '/home' do
  #session[:locale] = :en
  redirect to('/home/' + (session[:locale]).to_s)
end

get '/home/:lang' do |lang|
  session[:locale] = lang
  erb :index
end

post '/stats' do
    start = Time.now
    str = params[:text].to_s
    if str.length == 0
      erb :error_empty 
    else
    # @kek = params[:fname]
    no_spaces = str.gsub(/\s+/, "")
    comma = str.count ','
    period = str.count '.'
    str.gsub!(/[-]/, ' ') # Replace all hyphens with whitespaces for phrases like "Comment-allez vous?"
    str.gsub!(/[^a-zA-Zа-яА-Я0-9éèêëîïôùûüÿàœçÀÂÄÇÉÈÊËÎÏÔÖÙÛÜŸ ]/, '')    # keep only Latin and Russian letters and digits
    word_count = {} # empty hash for word count
    word_count.default = 0
    word_array = str.split
    word_array.each { |word| word_count[word] += 1} # count each word
    most_frequent = word_array.max_by {|word| word_array.count(word)}
    number_occurences = word_array.tally #this creates a hash
    highest_occurrence =  number_occurences[most_frequent] # the value (number) from the hash number_occurences
    
    all_frequents_hash = number_occurences.keep_if {| key, value | value == highest_occurrence } # keep only words that are frequent
    
     
     word_count = word_array.length()
     unique_words = word_array.uniq.length
     
    #"Size is #{str.size} and Length is #{str.length}"
    erb :stats, :locals => {:size => str.size, :size_small => no_spaces.size, :pages => (str.size/1800.0).round(3) , :comma => comma, :period => period, :most => most_frequent, :highest_occurrence => highest_occurrence, :start => start, :unique_words => unique_words, :word_count => word_count, :frequent_count => all_frequents_hash.keys }
    #"My name is #{params[:fname]}, and I love #{params[:lname]}."
    #"The length is #{params[:fname]}.size"
    end
end
