module Skyclient
  class ServiceInstance
    def initialize
      @client = Skyclient::Client.new
    end

    def create
      body = {
        "service_id" => @client.config.service_id,
        "plan_id" => @client.config.plan_id,
        "parameters" => @client.config.parameters
      }
      name = SecureRandom.uuid
      resp = @client.put("service_instances/#{name}", body)
      if resp.status == 201
        @client.config.instance_id = name
        @client.config.to_disk
      end
      self
    end

    def delete
      body = {
        "service_id" => @client.config.service_id,
        "plan_id" => @client.config.plan_id
      }
      resp = @client.delete("service_instances/#{@client.config.instance_id}", body)
      if resp.status == 200
        @client.config.instance_id = nil
        @client.config.osb_binding = nil
        @client.config.binding_id = nil
        @client.config.to_disk
        return self
      else
        raise "Could not delete instance"
      end
    end

    def bind
      binding_id = SecureRandom.uuid
      body = {
        "service_id" => @client.config.service_id,
        "plan_id" => @client.config.plan_id
      } 
      resp = @client.put("service_instances/#{@client.config.instance_id}/service_bindings/#{binding_id}", body)
      if resp.status == 201
        @client.config.binding_id = binding_id
        @client.config.osb_binding = resp.body
        @client.config.to_disk
        @client.config.write_env_file
      end
      self
    end
    def database_url
      @client.config.database_url
    end
  end
end