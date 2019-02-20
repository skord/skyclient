module Skyclient
  class Client
    attr_accessor :config
    def initialize
      if File.exist?(File.join(ENV['HOME'],".skyconfig"))
        @config = Skyclient::Config.new().from_disk
      else
        @config = Skyclient::Config.new().from_env
      end
    end

    def client
      Faraday.new(url: @config.osb_url) do |f|
        f.basic_auth(@config.username, @config.password)
        f.response  :json
        f.request :json
        f.adapter Faraday.default_adapter
      end
    end

    def get(path)
      client.get do |req|
        req.url path
        req.headers['x-broker-api-version'] = '2.14'
      end
    end

    def put(path,body)
      client.put do |req|
        req.url path
        req.body = body
        req.headers['x-broker-api-version'] = '2.14'
      end
    end

    def delete(path, body)
      client.delete do |req|
        req.url path
        req.body = body
        req.headers['x-broker-api-version'] = '2.14'
      end
    end

  end
end