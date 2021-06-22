require 'rubygems'
require 'bundler/setup'
require 'sinatra'
# configure { set :server, :Puma }
require 'i18n'
require 'odyssey'

enable :sessions

require 'uri'
require 'net/http'
require 'openssl'
require 'json'

require "lemmatizer"
require './common_words_array'

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
    @readability = params[:readability]
    @spelling = params[:spelling]
    @oxford_check = params[:oxford]
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
    
    if @readability == "1" 
    @flesch_kincaid_re = Odyssey.flesch_kincaid_re(str, false)
    @smog_grade = Odyssey.smog(str, false)
    @flesch_kincaid_re_level = case @flesch_kincaid_re
    when 90..150
      "Very easy to read (School grade: 5th)"
    when 80..90
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
      end
    
    if @spelling == "1"
    url = URI("https://dnaber-languagetool.p.rapidapi.com/v2/check")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

@text = str
@lang = session[:locale]

request = Net::HTTP::Post.new(url)
request["content-type"] = 'application/x-www-form-urlencoded'
request["x-rapidapi-key"] = '83fae76333msh71d08a19b6927e4p1ed439jsn1581f0b44304'
request["x-rapidapi-host"] = 'dnaber-languagetool.p.rapidapi.com'
request.body = "text=#{@text}&language=#{@lang}"

response = http.request(request)
@my_hash =  JSON.parse(response.body)
#my_hash['matches'].each {|k| 
#puts k['shortMessage']
#a = k['offset']
#b = k['length']
#puts a
#puts b
#puts 'Error: "' + text.slice(k['offset'], k['length']) + '"'
#puts k['offset'] + k['length']
#}
    end 
    
    
    sentences_array = str.split(/[.!?]/) # Get array of sentences (very roughly)
    words_in_sentences = [] # empty array to store the number of words in each sentence
    sentences_array.each { |kek| words_in_sentences << (kek.split).length } # Get the number of words in each sentence
    average_sentence_length = words_in_sentences.sum / words_in_sentences.length.to_f
    
    
    
    no_hyphen = str.gsub(/[-]/, ' ') # Replace all hyphens with whitespaces for phrases like "Comment-allez vous?"
    only_words = str.gsub(/[^a-zA-Zа-яА-Я0-9éèêëîïôùûüÿàœçÀÂÄÇÉÈÊËÎÏÔÖÙÛÜŸ ]/, '')    # keep only Latin and Russian letters and digits
    word_count = {} # empty hash for word count
    word_count.default = 0
    word_array = only_words.split
    word_array.each { |word| word_count[word] += 1} # count each word
    most_frequent = word_array.max_by {|word| word_array.count(word)}
    number_occurences = word_array.tally #this creates a hash
    highest_occurrence =  number_occurences[most_frequent] # the value (number) from the hash number_occurences
    
    all_frequents_hash = number_occurences.keep_if {| key, value | value == highest_occurrence } # keep only words that are frequent
    
    uppercase_word_array = word_array.map { |m| m.capitalize }
    lemmas = []
    lem = Lemmatizer.new
    
    no_proper_nouns = uppercase_word_array - $oxford # Remove words like "Bible" and "British"
    lowercase_word_array = no_proper_nouns.map { |m| m.downcase }  # Downcase remaining words: "Thinks" -> "thinks".
    
     lowercase_word_array.each { |b| lemmas <<  lem.lemma(b)} # "Find a lemma for each word: "Thinks" -> think"
     @rare_words = lemmas - $oxford # Keep only words that are not in Oxford 3000
     @rare_part = (@rare_words.length / lemmas.length.to_f * 100).to_i
     
     word_count = word_array.length()
     unique_words = word_array.uniq.length
     
     
    #"Size is #{str.size} and Length is #{str.length}"
    erb :stats, :locals => {:size => str.size, :size_small => no_spaces.size, :pages => (str.size/1800.0).round(3) , :comma => comma, :period => period, :most => most_frequent, :highest_occurrence => highest_occurrence, :start => start, :unique_words => unique_words, :word_count => word_count, :frequent_count => all_frequents_hash.keys, :words_in_sentences => words_in_sentences }
    #"My name is #{params[:fname]}, and I love #{params[:lname]}."
    #"The length is #{params[:fname]}.size"
    end
end
