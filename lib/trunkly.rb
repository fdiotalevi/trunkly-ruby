require 'net/http'
require 'uri'
require 'json'

module Trunkly
  
  class Trunkly
    
    attr_accessor :api_key
    
    LINKS = "http://trunk.ly/api/v1/links/"
    
    def initialize(key = nil)
      @api_key = key 
      @next_page = 0
      @prev_page = 0
      @last_used_params = {}
    end
    
    def links(params = {})
      @last_used_params = params 
      response = Net::HTTP.get_response(get_links(params))
      case response
      when Net::HTTPUnauthorized then
        raise AuthorizationError, "Unauthorized: no or wrong api_key"
      else
        links = []
        result = JSON.parse(response.body)
        @prev_page = result['prev_page'] || 0
        @next_page = result['next_page'] || 0
        result['links'].each do |it| 
          links << Link.new(it) 
        end
        links
      end
    end
    
    def next_page
      puts @last_used_params
      @last_used_params[:page] = @next_page
      links @last_used_params
    end
    
    def prev_page
      @last_used_params[:page] = @prev_page
      links @last_used_params      
    end
    alias :previous_page :prev_page
        
    private
    
    def get_links(params = {})
      userpart = params[:user] ? "#{params[:user]}/" : "";
      URI.parse(LINKS + userpart + query_string(params))
    end
    
    
          
    def query_string(params = {})
      query_string = ""
      params.each_pair do |k, v|
        query_string += "&#{k.to_s}=#{v}" unless k == :user
      end
      query_string += "&api_key=#{@api_key}" if @api_key #adds api key if available
      query_string[0] = '?' if query_string[0] == '&'
      query_string
    end
          
          
  end
  
  class Link
    
    attr_accessor :url, :lid, :title, :note, :dt_string, :tags
    
    def initialize(params)
      @url = params['url']
      @lid = params['lid']      
      @title = params['title']      
      @note = params['note']      
      @dt_string = params['dt_string']           
      @tags = params['tags'] 
      @tags = [@tags] if @tags.class == String
    end
    
    def to_s
      "title: #{@title}\nurl: #{@url}\ntags: #{@tags.join(',')}\n\n"
    end
  end    
  
  
  class AuthorizationError < StandardError
  end
  
end  