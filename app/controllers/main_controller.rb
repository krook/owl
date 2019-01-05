# Copyright 2018 Bryan Knouse, Magus Pereira, Charlie Evans, Taraqur Rahman, Nick Feuer
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class MainController < ApplicationController
  skip_before_action :verify_authenticity_token

  #################### Web Pages

  def index
    render layout: "landing"
  end

  def landing
    render layout: "landing"
  end

  def owldetails
    render layout: "landing"
  end

  def clusterduck
    render layout: "landing"
  end

  def opensource
    render layout: "landing"
  end

  def civdata
    render layout: "landing"
  end

  def duckportal
    render layout: "portal"
  end

  def home
    if signed_in?
      @message = Message.new
    else
      redirect_to "/signin"
    end

    @notifications = Notification.all.order(created_at: :desc).limit(7)
    @incidents = Incident.all.order(created_at: :desc)
    @incident = Incident.find(current_user.incident.to_i)
  end

  def search
    @us = []

    User.all.order(username: :asc).each_with_index do |f, index|
      @el = {
        value: f.username,
        label: f.name.to_s.capitalize,
        id: f.id
      }

      @us.push(@el)
    end
    @us = @us.to_json

    @newmessage = Message.new
  end

  def weather
    
  end

  def civilian
    @newclaim = Claim.new
  end




  ##################### DATABASE API ROUTES TO PUSH AND PULL DATA



  ###### set user main incident

  def setuserincident

    @uid = params[:user]
    @iid = params[:incident]

    @u = User.find(@uid)
    @u.incident = @iid
    @u.save
    
  end

  def getincidents

    @incidents = Incident.all.order(created_at: :desc).map do |u|
      { :name => u.name, :date => u.created_at.strftime("%l:%M%P %b %d"), id: u.id }
    end

    @ijson = @incidents.to_json

    respond_to do |format|
      format.json {render json: @ijson }
    end

  end

  def getincidentlocation
    @i = Incident.find(current_user.incident.to_i)
    @l = @i.location

    respond_to do |format|
      format.text {render plain: @l }
    end
  end


  ###### messaging API to get messages, set messages as read, etc.

  def getusername
    @u = params[:id]
    @username = User.find(@u).username
    respond_to do |format|
      format.text { render plain: @username }
    end
  end
  
  def getdirectmessages
    @u1 = params[:sender]
    @u2 = params[:recipient]
    @messages = []
    Message.where("sender = ? AND recipient = ?", @u1.to_i, @u2.to_i).order(created_at: :desc).each do |f|
      @m = [f.sender, f.message, f.created_at.to_i]
      @messages.push(@m)
    end
    Message.where("sender = ? AND recipient = ?", @u2.to_i, @u1.to_i).order(created_at: :desc).each do |f|
      @m = [f.sender, f.message, f.created_at.to_i]
      @messages.push(@m)
    end
    @messages = @messages.sort {|a,b| a[2] <=> b[2]}
    respond_to do |format|
      # format.html { redirect_to "/", notice: 'Gene created.' }
      format.js { render action: 'getdirectmessages' }
    end
  end

  def setmessageread

    # get message from API request
    @m = params[:mid]

    # find details about this message, like sender and recipient
    @message = Message.find(@m)
    @r = @message.recipient
    @s = @message.sender

    # set all messages in these two users' thread to "read=true" because maybe several were unread
    @fullthreadmessages = Message.where("sender = ? AND recipient = ?", @s, @r)
    @fullthreadmessages.each do |f|
      f.read = true
      f.save
    end

  end

  ######### Create random users

  def createuser
    @username = params[:username]
    @name = params[:name]

    @u = User.create(username: @username, name: @name, password: "password", password_digest: "password")
    @u.save
  end



  ######## create and read notifications

  def createnotification

    @title = params[:title]
    @text = params[:text]
    @twitter = params[:twitter]
    @n = Notification.create(title: @title, content: @text)
    @n.save

  end

  def createpriority

    @title = params[:title]
    @text = params[:text]
    @p = Priority.create(name: @title, details: @text)
    @p.save

  end

  def checknotifications
    @ns = Notification.order(created_at: :desc).first

    respond_to do |format|
      format.text { render plain: @ns.id }
    end
  end

  def checkpriorities
    @ns = Priority.order(created_at: :desc).first

    respond_to do |format|
      format.text { render plain: @ns.id }
    end
  end

  def getnotification
    @ns = Notification.order(created_at: :desc).first

    respond_to do |format|
      format.json {render json: {title: @ns.title, content: @ns.content, nid: @ns.id} }
    end
  end

  def getpriority
    @ns = Priority.order(created_at: :desc).first

    respond_to do |format|
      format.json {render json: {title: @ns.name, content: @ns.details, nid: @ns.id} }
    end
  end


  ######### create a new incident
  def newincident

    @n = params[:name]
    @l = params[:location]

    @i = Incident.create(name: @n, location: @l, managers: current_user.id.to_s)

    @u = current_user
    @u.incident = @i.id

    @u.save
    @i.save

  end





  ######################## clusterduck input data
  def clusterduckdata

    @data = request.body.read.to_s


    puts " "
    puts "------- request clusterduck"
    # puts request
    # puts request.body
    # puts request.body.read
    # puts request.params
    # puts request.headers
    puts @data

    puts "------- end request"
    puts " "

    # @params = params[]

    Clusterdatum.create(content: @data)

    respond_to do |format|
      format.text { render plain: "Hi Magus" }
    end

  end

  def clusterdata
    @clusterdata = Clusterdatum.all.order(created_at: :desc)
  end





  ######################## Twilio commands SMS Texting and Phone Calls

  def sendtext

  	@account_sid = ENV['TWILIO_SID']
  	@auth_token = ENV['TWILIO_AUTHTOKEN']
  	@client = Twilio::REST::Client.new @account_sid, @auth_token
  	if params[:message].blank?
  		@message = 'Hi there, this is OWL.'
  	else
  		@message = params[:message]
  	end

  	@client.messages.create(
  		:from => '+14847256467',
  		:to => '+14843472216',
  		:body => @message
  	)

  end

  def sendcall

    @account_sid = ENV['TWILIO_SID']
    @auth_token = ENV['TWILIO_AUTHTOKEN']
  	@client = Twilio::REST::Client.new @account_sid, @auth_token

  	@client.calls.create(
  		:from => '+14847256467',
  		:to => '+14843472216',
  		method: "GET",
  	    url: "http://s3.amazonaws.com/responsivetech/assets/call.xml"
  	)
  end




  ###################### IBM WATSON API INTELLIGENCE COMMANDS

  def analyzetone

  	##### IBM Watson Tone Analyzer

    @text = params[:text]

    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://gateway.watsonplatform.net/tone-analyzer/api/v3/tone?text=" + @text + "&version=2017-09-21&sentences=true")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "application/json"
    request.body = JSON.dump({

    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    

    respond_to do |format|
      # format.html { redirect_to "/", notice: 'Gene created.' }
    	format.js { render action: 'tone' }
    end
  end

  def visualizer

    ##### IBM Watson Visual Recognition API

    # @imgurl = params[:url]
    @imgurl = "https://s3.amazonaws.com/responsivetech/assets/bmd02.jpg"
    # @imgurl = "https://s3.amazonaws.com/responsivetech/assets/dogtest02.jpg"

    # @endpoint = "https://gateway.watsonplatform.net/visual-recognition/api/v3/classify?version=2016-05-17&classifier_ids=DefaultCustomModel_2101976&url=" + @imgurl
    @endpoint = "https://gateway.watsonplatform.net/visual-recognition/api/v3/classify?version=2016-05-17&url=" + @imgurl

    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://gateway.watsonplatform.net/visual-recognition/api/v3/classify?version=2016-05-17&url=" + @imgurl)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "application/json"
    request.body = JSON.dump({

    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts " "
    puts @response
    puts "----- visualizer"
    puts @vjson
    puts " "
    puts "----- images"
    puts @images
    puts " "
    puts "----- classifiers"
    puts @classifiers
    puts " "
    puts "----- classes"
    puts @classes

      respond_to do |format|
        # format.html { redirect_to "/", notice: 'Gene created.' }
        format.js { render action: 'visual' }
      end
  end

  def classifier

  	##### IBM Watson Natural Language Classifier allowing us to create custom voice text models

  	@text = params[:text]
  	@text = "how hot will it be outside today?"

    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/10D41B-nlc-1/classify?text=" + @text)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "application/json"
    request.body = JSON.dump({

    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

  end

  def nlu

  	##### IBM Watson Natural Language Understanding Base models for text

  	# @text = params[:text]
  	@text = "IBM is an American multinational technology company headquartered in Armonk, New York, United States, with operations in over 170 countries."

  	# @features = "concepts,categories,emotion,entities,keywords,metadata,relations,semantic_roles,sentiment"
  	@features = "keywords,entities"

    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2018-03-16&features=" + @features + "&text=" + @text)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "application/json"
    request.body = JSON.dump({

    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end


  end

  def stt
    # @text = params[:text]
    # if @text.to_s == ""
    #   @text = "hello world!"
    # end

    # require 'net/http'
    # require 'uri'
    # require 'json'

    # uri = URI.parse("https://gateway.watsonplatform.net/language-translator/api/v3/translate?version=2018-05-01")
    # request = Net::HTTP::Post.new(uri)
    # request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    # request.content_type = "application/json"
    # request.body = JSON.dump({
    #   "text" => [
    #     @text
    #   ],
    #   "model_id" => "en-es"
    # })

    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }

    # @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end
    
    # respond_to do |format|
    #   format.text { render plain: @response.body }
    # end
  end

  def tts
  	@endpoint = "https://stream.watsonplatform.net/text-to-speech/api"
  end

  def translator

    ###### this is the translator page
    translatelanguages

  end

  def translate

    ###### this is the translate text API route

    @text = params[:text]
    if @text.to_s == ""
      @text = "hello world!"
    end
    
    @startlang = params[:startlang]
    if @startlang.to_s == ""
      @startlang = "en"
    end

    @targetlang = params[:targetlang]
    if @targetlang.to_s == ""
      @targetlang = "es"
    end

    @model = @startlang + "-" + @targetlang

    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://gateway.watsonplatform.net/language-translator/api/v3/translate?version=2018-05-01")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "application/json"
    request.body = JSON.dump({
      "text" => [
        @text
      ],
      "model_id" => @model
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts " "
    puts "----translator"
    puts " model"
    puts @model
    puts @response.body
    puts " "
    puts @response
    
    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end

  def identifylanguage

    @text = params[:text]
    if @text.to_s == ""
      @text = "hello world!"
    end

    require 'net/http'
    require 'uri'

    uri = URI.parse("https://gateway.watsonplatform.net/language-translator/api/v3/identify?version=2018-05-01")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "text/plain"
    request.body = @text

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts " "
    puts "----translator"
    puts @response.body
    puts " "
    puts @response
    
    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end

  def translatelanguages
    
    require 'net/http'
    require 'uri'

    uri = URI.parse("https://gateway.watsonplatform.net/language-translator/api/v3/identifiable_languages?version=2018-05-01")
    request = Net::HTTP::Get.new(uri)
    request.basic_auth("apikey", ENV['WATSON_APIKEY'])
    request.content_type = "text/plain"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    # puts " "
    # puts "---- get translate languages"
    # puts @response.body
    # puts " "
    # puts @response
    
    # respond_to do |format|
    #   format.text { render plain: @response.body }
    # end
  end






  ############### The weather company weather api data routes

  def getweatheralerts

    @geoid = params[:geoid]

    if @geoid.to_s == "undefined" || @geoid.to_s == ""
      @geoid = ""
    end

    require 'uri'
    require 'net/http'

    # includes below a geoid so you can localize
    url = URI("https://api.weather.com/v2/stormreports?apiKey=" + ENV['WEATHER_APIKEY'] + "&format=json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- weather alerts"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end

  end


  def getweatherforecast

    if params[:geoid].to_s == "" || params[:geoid].to_s == "undefined"
      @geocode = "35.613,-77.366"
    else
      @geocode = params[:geoid]
    end

    puts @geocode
    
    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v3/wx/forecast/daily/3day?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&units=e%0A&format=json&geocode=" + @geocode)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    # puts " "
    # puts "----- weather forecast"
    # puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end


  def get15minforecast

    if params[:location].to_s == ""
      @location = "40.712399/-73.964152"
    else
      @location = params[:location]
    end

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v1/geocode/" + @location + "/forecast/fifteenminute.json?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&units=e")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- 15 min weather forecast"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end



  def getlocation

    @location = params[:location]

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v3/location/search?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&format=json&query=" + @location)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Find Location"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end

  end


  def weathernowcast

    if params[:location].to_s == ""
      @location = "40.712399/-73.964152"
    else
      @location = params[:location]
    end

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v1/geocode/" + @location + "/forecast/nowcast.json?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&units=e")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Weather Nowcast"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end

  def powerdisruption

    if params[:location].to_s == ""
      @location = "40.712399,-73.964152"
    else
      @location = params[:location]
    end

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v2/indices/powerDisruption/daypart/15day?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&format=json&geocode=" + @location)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Power Disruption"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end


  def tropicalforecast

    @basin = "AL"

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v2/tropical/projectedpath?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&format=json&units=e&nautical=true&source=all&basin=" + @basin)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Tropical Forecast"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end


  def tropicalcurrent

    @basin = "AL"

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v2/tropical/currentposition?apiKey=" + ENV['WEATHER_APIKEY'] + "&units=e&language=en-US&format=json&nautical=true&source=all&basin=" + @basin)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Tropical Storm Current Position"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end


  def weatheralmanac

    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v3/wx/almanac/daily/5day?apiKey=" + ENV['WEATHER_APIKEY'] + "&units=e&geocode=40.712399%2C-73.964152&startDay=22&startMonth=08&format=json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Weather Almanac"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end

  def currentsondemand
    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v3/wx/observations/current?apiKey=" + ENV['WEATHER_APIKEY'] + "&units=e&geocode=40.712399%2C-73.964152&language=en-US&format=json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Currents on Demand"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end

  def siteobservations
    require 'uri'
    require 'net/http'

    url = URI("https://api.weather.com/v1/geocode/40.712399/-73.964152/observations.json?apiKey=" + ENV['WEATHER_APIKEY'] + "&language=en-US&units=e")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept-encoding"] = 'application/gzip'
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    @response = http.request(request)
    puts " "
    puts "----- Site based observations, current condition"
    puts @response.read_body

    respond_to do |format|
      format.text { render plain: @response.body }
    end
  end



end
