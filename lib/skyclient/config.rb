module Skyclient
  class Config
    attr_accessor :username, :password, :url, :service_id,
                  :plan_id, :parameters, :instance_id, :osb_binding,
                  :binding_id
    def initialize
      @username = nil
      @password = nil
      @url = nil
      @service_id = nil
      @plan_id = nil
      @parameters = nil
      @instance_id = nil
      @osb_binding = nil
      @binding_id = nil
    end

    def from_env
      if ENV['SKYSQL_AUTH'].nil?
        raise "SKYSQL_AUTH environment variable not set"
      else
        config = JSON.parse(Base64.decode64(ENV['SKYSQL_AUTH']))
        @username = config.fetch('username')
        @password = config.fetch('password')
        @url = config.fetch('url')
        @service_id = config.fetch('service_id',nil)
        @plan_id = config.fetch('plan_id', nil)
        @parameters = config.fetch('parameters', nil)
        @instance_id = config.fetch('instance_id', nil)
        @osb_binding = config.fetch('binding', nil)
        @binding_id = config.fetch('binding', nil)
        self
      end
    end

    def to_env
      Base64.encode64({
        "username" => @username,
        "password" => @password,
        "url" => @url,
        "service_id" => @service_id,
        "plan_id" => @plan_id,
        "parameters" => @parameters,
        "instance_id" => @instance_id,
        "binding" => @osb_binding,
        "binding_id" => @binding_id
      }.to_json).gsub("\n","")
    end
    
    def to_disk
      attrs = {
        "username" => @username,
        "password" => @password,
        "url" => @url,
        "service_id" => @service_id,
        "plan_id" => @plan_id,
        "parameters" => @parameters,
        "instance_id" => @instance_id,
        "binding" => @osb_binding,
        "binding_id" => @binding_id
      }.to_json 
      File.open(File.join(ENV['HOME'],".skyconfig"),"w") do |f|
        f.puts attrs 
      end
    end

    def from_disk
      attrs = JSON.parse(File.read(File.join(ENV['HOME'],".skyconfig")))
      self.username = attrs.fetch('username')
      self.password = attrs.fetch('password')
      self.url = attrs.fetch('url')
      self.service_id = attrs.fetch('service_id')
      self.plan_id = attrs.fetch('plan_id')
      self.parameters = attrs.fetch('parameters')
      self.instance_id = attrs.fetch('instance_id')
      self.osb_binding = attrs.fetch('binding')
      self.binding_id = attrs.fetch('binding_id')
      self
    end

    def osb_url
      uri = URI.parse(@url)
      uri.path = "/osb/v2"
      uri.to_s
    end

    def database_url
      creds = @osb_binding.fetch('credentials')
      "mysql://#{creds['username']}:#{creds['password']}@#{creds['hostname']}:#{creds['port']}/#{creds['name']}"
    end

    def write_env_file
      File.open(File.join(ENV['HOME'],".tempest_env"),"w") do |f|
        f.puts "DATABASE_URL=#{database_url}"
      end
    end
  end
end