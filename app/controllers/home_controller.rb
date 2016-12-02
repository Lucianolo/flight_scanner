require 'json'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'uri'

class HomeController < ApplicationController
  def index
    puts session[:id]
    if session[:id] == 10
      @codes = to_code.keys
    else
      redirect_to login_index_path
    end
  end
  
  def search
    
    apiKey = "AIzaSyADlb82ZnSIwyE-UtfZSla_Itd8QHj_0Ms"
    originPlace = to_code[params[:origin]]
    destinationPlace = to_code[params[:destination]]
    
    
    outboundPartialDate = params[:outbound]
    inboundPartialDate = params[:inbound]
    adults = params[:adults]
    children = params[:children]
    val = params[:value]
    
    @incremento = params[:incremento]
    if val!= ""
      @value = (val.to_i)/100.0
    else
      @value = 0
    end
    
    if inboundPartialDate == "" 
      @payload = 
      {
       "request": {
        "passengers": {
         "adultCount": adults,
         "childCount": children
        },
        "slice": [
         {
          "origin": originPlace,
          "destination": destinationPlace,
          "date": outboundPartialDate
         }
        ],
        "solutions": 10
       }
      }
      
    else
      
      @payload = 
  
      {
       "request": {
        "passengers": {
         "adultCount": adults,
         "childCount": children
        },
        "slice": [
         {
          "origin": originPlace,
          "destination": destinationPlace,
          "date": outboundPartialDate
         },
         {
          "origin": destinationPlace,
          "destination": originPlace,
          "date": inboundPartialDate
         }
        ],
        "solutions": 10
       }
      }
    end
    
    uri = URI.parse("https://www.googleapis.com/qpxExpress/v1/trips/search?fields=kind%2Ctrips&key="+apiKey+"")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(
      uri.request_uri, 
      'Content-Type' => 'application/json'
    )
    req.body = @payload.to_json
    res = http.request(req)
    
    
    # RESPONSE ANALISIS
    
    
    parsed = JSON.parse(res.body)
    
    data_temp = parsed["trips"]
    
    @carriers = {}
    @airports = {}
    
    
    #puts parsed
    
    if data_temp != nil
      if(data_temp["data"].keys.count > 1)
        data_temp["data"]["carrier"].each do |carrier|
          @carriers[carrier["code"]] = carrier["name"]
        end
        data_temp["data"]["airport"].each do |airport|
          @airports[airport["code"]] = airport["name"]
        end
        @data = data_temp["tripOption"]
        
        
        @websites = carrier_websites
        
        
        
      end
    else
      @empty = true
    end
  end
  

private 

  def to_code
    #page = Nokogiri::HTML(open("http://www.nationsonline.org/oneworld/IATA_Codes/airport_code_list.htm"))  
    file = File.read('codes.html')
    page = Nokogiri::HTML(file)
    #File.write('codes.html', page)
    index = 0
    
    codes = {}
    page.search('table.tb86').search('tr').each do |item|
      if index<1
        index += 1
        next
      else
        if (item.search('td.border1').first.nil? || item.search('td.border1').last.nil?)
          index += 1
          next
        else
          name = (item.search('td.border1').first.text).gsub(/\n/, "")
          code = (item.search('td.border1').last.text).gsub(/\n/, "")
          
          codes[name] = code
          index += 1
        end
      end
    end
    return codes
  end
  
  def carrier_websites
    #page = Nokogiri::HTML(open("https://www.onetravel.com/travel/travelcodes.asp"))  
    #File.write('websites.html', page)
    file = File.read('websites.html')
    page = Nokogiri::HTML(file)
    websites = {}
    page.search('.airlineCode').each do |line|
      line.search('ul li').each do |item|
        code = item.search('span').text
        website = "http://"+item.search('a').first["href"][2..-2]
        websites[code] = website
      end
    end
    return websites
  end
  
end
