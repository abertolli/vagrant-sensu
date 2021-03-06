# encoding: UTF-8
require 'json'


Puppet::Type.type(:sensu_server_checks).provide(:checks) do
  @doc = <<-EOS 
  EOS

  confine :osfamily => [:RedHat, :Debian]
  defaultfor :operatingsystem => :RedHat

  def check_params
    check_hash = {}

    if @resource[:checks].nil? && @resource[:command].nil? && @resource[:subscribers] && @resource[:interval].nil? && @resource[:config_file].nil?
      fail('A check, command, list of subscriptions, interval and configuration file are required')
    end

    check_hash['command'] = @resource[:command] unless @resource[:command].nil?
    check_hash['subscribers'] = @resource[:subscribers] unless @resource[:subscribers].nil?
    check_hash['interval'] = @resource[:interval].to_i unless @resource[:interval].nil?
    check_hash['type'] = @resource[:type] unless @resource[:type].nil?
    check_hash['extension'] = @resource[:extension] unless @resource[:extension].nil?
    check_hash['standalone'] = @resource[:standalone] unless @resource[:standalone].nil?
    check_hash['publish'] = @resource[:publish] unless @resource[:publish].nil?
    check_hash['timeout'] = @resource[:timeout].to_i unless @resource[:timeout].nil?
    check_hash['ttl'] = @resource[:ttl].to_i unless @resource[:ttl].nil?
    check_hash['handle'] = @resource[:handle] unless @resource[:handle].nil?
    check_hash['handler'] = @resource[:handler] unless @resource[:handler].nil?
    check_hash['low_flap_threshold'] = @resource[:low_flap_threshold].to_i unless @resource[:low_flap_threshold].nil?
    check_hash['high_flap_threshold'] = @resource[:high_flap_threshold].to_i unless @resource[:high_flap_threshold].nil?
    check_hash['source'] = @resource[:source] unless @resource[:source].nil?
    check_hash['aggregate'] = @resource[:aggregate] unless @resource[:aggregate].nil?
    check_hash['handlers'] = @resource[:handlers] unless @resource[:handlers].nil?
    check_hash['subdue'] = @resource[:subdue] unless @resource[:subdue].nil?

    check_hash
  end

  def create
   sensu_client_hash = {}
   new_hash = {}
   info("checking if #{@resource[:config_file]} needs contents modified")
   myjson_hash = check_params
   sensu_client_hash["#{@resource[:checks]}"] = myjson_hash
   new_hash['checks'] = sensu_client_hash
   #warn("This is myjson_hash #2: #{myjson_hash}")
   #warn("This is sensu_client_hash #2: #{sensu_client_hash}")
   #warn("This is new_hash #2: #{new_hash}")
   myfile = File.open(@resource[:config_file], "w")
   myfile.write(JSON.pretty_generate new_hash)
   myfile.close
     
  end

  def destroy
    info("destroying #{@resource[:config_file]} contents")
    blank_hash = {}
    emptyfile = File.open(@resource[:config_file], "w")
    emptyfile.write(JSON.pretty_generate blank_hash)
  end

  def check
    myhash = check_params
    json_not_in_file = 0
    opened_file = File.read("#{@resource[:config_file]}")
    begin
      file_hash = JSON.parse(opened_file)
    rescue
      debug("The contents of #{@resource[:config_file]} is not in json format")
      json_not_in_file += 1
    end
  
   if json_not_in_file == 0
    sensu_value = 0
    myhash.each do | k, v |
      #puts "key: #{k} value: #{v}...value class: #{v.class}"
      if file_hash["checks"][@resource[:checks]]["#{k}"].is_a?(Array)
        if "#{file_hash["checks"][@resource[:checks]]["#{k}"]}" == "#{v}"
          debug("#{k} is an Array!")
          #puts "first value:#{file_hash["checks"][@resource[:checks]]["#{k}"]}..value:#{v}"
        else
          debug("Reached the end of the array checks!")
          #puts "first value:#{file_hash["checks"][@resource[:checks]]["#{k}"]}..value:#{v}"
          sensu_value += 1
        end
      elsif file_hash["checks"][@resource[:checks]]["#{k}"].is_a?(Fixnum)
        if "#{file_hash["checks"][@resource[:checks]]["#{k}"]}" == "#{v.to_i}"
          debug("#{k} is a Fixnum!")
        else
          debug("Reached the end of the fixnum checks!")
          #puts "first value:#{file_hash["checks"][@resource[:checks]]["#{k}"]}..value:#{v}"
          sensu_value += 1
        end
      elsif file_hash["checks"][@resource[:checks]]["#{k}"].is_a?(String)
        if "#{file_hash["checks"][@resource[:checks]]["#{k}"]}" == "#{v}"
          debug("#{k} is a String!")
        else
          debug("Reached the end of the string checks!")
          sensu_value += 1
        end
      else
        debug("Reached the end of the loop!")
        sensu_value += 1
      end
    end

     if json_not_in_file == 1
       return false
     elsif file_hash.empty?
       return false
     elsif "#{@resource[:ensure]}" == 'absent'
       return true
     elsif sensu_value > 0
      return false
     else
       #puts "I am exiting sensu_value: #{sensu_value}"
       #puts "this is the sensu_value file: #{sensu_value}"
       #puts "this is the sensu_value file: #{json_not_in_file}"
       return true
     end
    end
  end

  def exists?
    if File.exists?("#{@resource[:config_file]}")
       check 
    else
       check
    end
  end
end
