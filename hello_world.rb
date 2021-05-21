require 'rubygems'
require 'bundler/setup'
require 'sinatra'
# configure { set :server, :Puma }
require 'i18n'
require 'odyssey'
enable :sessions

I18n.load_path << Dir[File.expand_path("locales") + "/*.yml"]
I18n.default_locale = :en

get '/' do
  redirect to('/home/en')
end

get '/home/?' do
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
    @count_dots = params[:count_dots]
    @count_sentences = params[:count_sentences] 
    if str.length == 0
      erb :error_empty 
    else
    # @kek = params[:fname]
    no_spaces = str.gsub(/\s+/, "")
    comma = str.count ','
    period = str.count '.'
    @exclamation = str.count '!'
    @question = str.count '?'
    @en_dash = str.count '–'
    @em_dash = str.count '—'
    @flesch_kincaid_re = Odyssey.flesch_kincaid_re(str, false)
    @smog_grade = Odyssey.smog(str, false)
    @flesch_kincaid_re_level = case @flesch_kincaid_re
    when 90..150
      "Very easy to read (School grade: 5th)"
    when 80..80
      "Easy to read (School grade: 6th)"
    when 70..80
      "Fairly easy to read (School grade: 7th)"
    when 60..70
      "Plain English (School grade: 8th & 9th)"
    when 50..60
      "Fairly difficult to read (School grade: 10th to 12th)"
    when 30..50
      "Difficult to read (College)"
    when 10..30
      "Very difficult to read (College graduate)"
    when 0..10
      "Extremely difficult to read. Best understood by university graduates."
     else
       "Not available."
      end
    
    
    sentences_array = str.split(/[.!?]/) # Get array of sentences (very roughly)
    words_in_sentences = [] # empty array to store the number of words in each sentence
    sentences_array.each { |kek| words_in_sentences << (kek.split).length } # Get the number of words in each sentence
    average_sentence_length = words_in_sentences.sum / words_in_sentences.length.to_f
    
    
    
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
    erb :stats, :locals => {:size => str.size, :size_small => no_spaces.size, :pages => (str.size/1800.0).round(3) , :comma => comma, :period => period, :most => most_frequent, :highest_occurrence => highest_occurrence, :start => start, :unique_words => unique_words, :word_count => word_count, :frequent_count => all_frequents_hash.keys, :words_in_sentences => words_in_sentences }
    #"My name is #{params[:fname]}, and I love #{params[:lname]}."
    #"The length is #{params[:fname]}.size"
    end
end
