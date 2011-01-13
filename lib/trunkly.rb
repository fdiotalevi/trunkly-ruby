require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

module Trunkly
  
  class Trunkly
    
    attr_accessor :api_key
    
    LINKS = "http://trunk.ly/api/v1/links/"
    LINK = "http://trunk.ly/api/v1/link/"    
    TIMELINE = "http://trunk.ly/api/v1/timeline/"
    
    def initialize(key = nil)
      @api_key = key 
      @last_used_params = {}
      @last_command = :links
      @next_page, @prev_page = 0, 0
    end
    
    def timeline(params = {})
      @last_used_params = params       
      @last_command = :timeline      
      retrieve_links_from(get_timeline(params))
    end
    
    def links(params = {})
      @last_used_params = params      
      @last_command = :links
      retrieve_links_from get_links(params) 
    end
    
    def save(link = Link.new)
      raise ArgumentError, "save method parameter must be a Trunkly::List" unless link.class == Link
      yield link if block_given?
      post_params = link.to_hash
      post_params[:api_key] = @api_key
      response = Net::HTTP.post_form(URI.parse(LINK), post_params)    
      case response
      when Net::HTTPSuccess
        response
      else
        raise ApiError, "Exception trying to save a link: "+response.body.to_s
      end
    end
    
    def next_page
      @last_used_params[:page] = @next_page
      send @last_command.to_sym, @last_used_params
    end
    
    def prev_page
      @last_used_params[:page] = @prev_page
      send @last_command.to_sym, @last_used_params
    end
    alias :previous_page :prev_page
    
    def method_missing(method_id, *args)
      if method_id.to_s =~/^links_by_(.*)/
        args << {} if args.size == 0
        args[0][:user] = $1
        links args[0]
      else
        super
      end
    end
    
        
    private
    
    def retrieve_links_from(url)
      response = Net::HTTP.get_response(url)
      case response
      when Net::HTTPUnauthorized then
        raise AuthorizationError, "Unauthorized: no or wrong api_key"      
      when Net::HTTPSuccess
        extract_links_from response
      else 
        raise ApiError, "Exception trying to get links: "+response.body.to_s
      end
    end  
    
    def extract_links_from(response)
      result = JSON.parse(response.body)
      @prev_page, @next_page = result['prev_page'] || 0, result['next_page'] || 0
      result['links'].map do |it| 
        Link.new(it) 
      end
    end
    
    
    def get_timeline(params = {})
      URI.parse(URI.escape(TIMELINE) + query_string(params))
    end
    
    
    def get_links(params = {})
      userpart = params[:user] ? "#{params[:user]}/" : "";
      URI.parse(URI.escape(LINKS + userpart + query_string(params)))
    end    
          
    def query_string(params = {})
      query_string = ""
      params.each_pair do |k, v|
        query_string += "&#{k.to_s}=#{v}" unless k == :user
      end
      query_string += "&api_key=#{@api_key}" if @api_key #adds api key if available
      query_string[0] = '?' if query_string[0] == 38  #replace initial &
      query_string
    end
          
  end
  


  class Link
    
    attr_reader :lid, :dt_string, :tags
    attr_accessor :url, :title, :note
    
    def initialize(params = {})
      %w[url lid title dt_string note url tags].each { |it| set_param(params, it) }
      @tags = [@tags] if @tags.class == String
      @tags = [] unless @tags
    end
    
    def tags=(some_tags)
      if some_tags.class == String
        @tags = some_tags.split(',') 
      else
        @tags = some_tags
      end
    end
    
    def to_s
      "title: #{@title}\nurl: #{@url}\ntags: #{@tags.join(',')}\n\n"
    end
    
    def to_hash
      params = {}
      %w[url lid title dt_string note url].each { |it| hash_param(params, it) }
      params['tags'] = @tags.join(',') if @tags
      params
    end
    
    def hash_param(params, name)
      params[name] = instance_variable_get("@#{name}") if instance_variable_get("@#{name}")
    end
    
    def set_param(params, name)
      instance_variable_set("@#{name}", params[name])
    end
    
  end    
  
  
  class AuthorizationError < StandardError
  end
  
  class ApiError < StandardError
  end
end  
