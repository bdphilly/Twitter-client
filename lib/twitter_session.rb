require 'oauth'
require 'launchy'
require 'yaml'
require 'json'

class TwitterSession

  def self.consumer_key
    File.read(Rails.root.join('.api_key')).chomp
  end

  def self.consumer_secret
    File.read(Rails.root.join('.api_secret')).chomp
  end

  CONSUMER_KEY = self.consumer_key
  CONSUMER_SECRET = self.consumer_secret

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  TOKEN_FILE = "./../access_token.yml"

  def self.get(path, query_values = nil)
    uri_get = path_to_url(path, query_values)
    response = access_token.get(uri_get).body
    JSON.parse(response)
  end

  def self.post(path, req_params = nil)3
    uri_post = path_to_url(path, req_params)
    response = access_token.post(uri_post).body
    JSON.parse(response)
  end

  def self.access_token
    if File.exist?(TOKEN_FILE)
      # reload token from file
      File.open(TOKEN_FILE) { |f| YAML.load(f) }
    else
      raise "No YAML file!"
    end
  end

  def self.request_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url


    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    # Because we don't use a redirect URL; user will receive a short PIN
    # (called a **verifier**) that they can input into the client
    # application. The client asks the service to give them a permanent
    # access token to use.
    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )

    # The `OAuth::AccessToken` object lets us make HTTP requests on behalf
    # of the user. It has the same methods as restclient. Unlike
    # restclient, requests made using this token will also include the
    # client keys and the user's access token, so that the service can
    # make sure the request is properly authorized.
    # response = access_token

   if File.exist?(TOKEN_FILE)
     File.open(TOKEN_FILE) { |f| YAML.load(f) }
   else
     File.open(TOKEN_FILE, "w") { |f| YAML.dump(access_token, f) }
     access_token
   end
  end

  def self.path_to_url(path, query_values = nil)

    uri = Addressable::URI.new(
                  :scheme => "https",
                  :host => "api.twitter.com",
                  :path => "1.1/" + path + ".json",
                  :query_values => query_values
                ).to_s
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json".
  end
end