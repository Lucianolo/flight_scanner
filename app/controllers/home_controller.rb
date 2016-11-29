require 'json'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'uri'

class HomeController < ApplicationController
  def index
  end
  
  def search
    
    
    apiKey = "YOUR API KEY"
    originPlace = to_code(params[:origin])
    destinationPlace = to_code(params[:destination])
    
    
    outboundPartialDate = params[:outbound]
    inboundPartialDate = params[:inbound]
    adults = params[:adults]
    
    @payload = 

    {
     "request": {
      "passengers": {
       "adultCount": adults
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
    
    @data = parsed["trips"]["tripOption"]
   
    
    
  
  
  
=begin  
  uri = URI 'https://www.skyscanner.it/'

  form_page  = agent.get "https://www.skyscanner.it/"
  
  #pp form_page
  #res = form_page.search('form')
  form = form_page.form_with(:class => "clearfix")
  pp form
  form.fields.each { |f| puts f.name }
  puts form.to_s
=end  
  @resp = ""


=begin    
    post_params = { 
    :apiKey => "sp963399441614999385444677643713",
    :country => "IT",
    :currency => "EUR",
    :locale => "it-IT",
    :adults => 1,
    :children => 0,
    :infants => 0,
    :originplace => params[:origin],
    :destinationplace => params[:destination],
    :outbounddate => params[:outbound],
    :inbounddate => params[:inbound],
    :locationschema => 'Default',
    :cabinclass => 'Economy',
    :groupPricing => true
  }

  
  sessionkey_request = Net::HTTP.post_form(URI.parse('http://partners.api.skyscanner.net/apiservices/pricing/v1.0'), post_params )
  get_data= "http://partners.api.skyscanner.net/apiservices/pricing/v1.0/?apiKey=#{post_params[:apiKey]}"
  puts sessionkey_request.inspect
  temp = Net::HTTP.get_response(URI.parse(get_data)).body
  
  
    
    
    # ENDPOINTS : 
    # Skyscanner::Connection.browse_dates
    # Skyscanner::Connection.browse_grid
    # Skyscanner::Connection.browse_routes
    # Skyscanner::Connection.browse_quotes
    
    
    # CONFIGURATION :
    
    Skyscanner::Connection.apikey = "sp963399441614999385444677643713"
    Skyscanner::Connection.protocol = :http
    #Skyscanner::Connection.response_format = 'json'
    
    # Skyscanner::Connection.url = partners.api.skyscanner.net/apiservices/
    
    # API CALL :
    
    @resp = Skyscanner::Connection.browse_quotes({ :country => "IT", :currency => "EUR", :locale => "it-IT", :originPlace => originPlace, :destinationPlace => destinationPlace, :outboundPartialDate => outboundPartialDate, :inboundPartialDate => inboundPartialDate })
    
    status = @resp[:status]
    @resp = eval(@resp[:body])[:Quotes]
    puts @resp
=end


  end
  

private 

  def to_code(city)
    page = Nokogiri::HTML(open("http://www.nationsonline.org/oneworld/IATA_Codes/airport_code_list.htm"))  
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
          name = item.search('td.border1').first.text
          code = item.search('td.border1').last.text
          
          codes[name] = code
          index += 1
        end
      end
    end
    return codes[city]
  end
  
end
