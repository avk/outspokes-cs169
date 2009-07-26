# Extensions to Ruby's URI module and URI::HTTP class
module URIExtension
  
  # Based on:
  # 1. http://labs.apache.org/webarch/uri/rfc/rfc3986.html#comparison
  # 2. http://labs.apache.org/webarch/uri/rfc/rfc3986.html#components

  # Definitions:
  # 1. 'Authority' is [ userinfo "@" ] host [ ":" port ] 
  #     where brackets denote optional and userinfo, host, and port are instance methods of URI::HTTP
  #     e.g. "arthur@outspokes.com:3000" => userinfo: "arthur", host: "outspokes.com", port: 3000
  #     
  #     Authority ignores: 
  #     - a blank port (e.g. "outspokes.com:" => "outspokes.com")
  #     - a default port (e.g. "outspokes.com:80" => "outspokes.com")
  #     - a blank userinfo (e.g. "@outspokes.com" => "outspokes.com")
  #     - the "www" subdomain (e.g. "www.outspokes.com" => "outspokes.com")
  #     
  # 2. 'Base domain' is scheme://authority
  #     e.g. "http://outspokes.com" => scheme: "http", authority: "outspokes.com"
  # 
  # 3. 'Equivalent domains' are two URIs whose base domains are equivalent


  def base_domain(url)
    begin
      parsed = URI.parse(url)
      if parsed.scheme.nil?
        return nil
      end
      parsed.scheme + "://" + parsed.authority
    rescue URI::InvalidURIError 
      nil
    end
  end
  
  def same_domain?(url, another_url)
    first_base_domain = base_domain(url) 
    second_base_domain = base_domain(another_url)
    
    if first_base_domain.nil? or second_base_domain.nil?
      false
    else
      first_base_domain.downcase == second_base_domain.downcase
    end
  end
  
  
  module URIExtension::HTTP
    
    DEFAULT_PORT = 80
    
    def self.included(klass)
      klass.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def authority 
        # below, self is URI::HTTP
        auth = ''
        
        # test for existence because userinfo is optional
        if self.userinfo
          auth << "#{self.userinfo}@"
        end
        
        # ignore the "www" subdomain
        auth << self.host.sub(/^www\./i, '')
        
        # test for existence because port is optional
        if self.port and self.port != DEFAULT_PORT # ignore the default port
          auth << ":#{self.port}"
        end
        auth
      end
    end
  end

end

# Extend the originals
URI.extend(URIExtension)
URI::HTTP.send(:include, URIExtension::HTTP)
