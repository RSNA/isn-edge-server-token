require 'net/http'
require 'uri'
require 'cgi'

module SSO

  def self.sso_url
    URI(ENV["OPENAM_URL"])
  end

  def self.logout_url
    openam_url = sso_url
    openam_url.path+="/UI/Logout"
    openam_url
  end

  def self.get_redirect_url(goto_url)
    openam_url = sso_url
    openam_url.path+="/UI/Login"
    openam_url.query = "goto="+CGI.escape(goto_url)
    openam_url
  end

  def self.parse_return(rtn)
    if !rtn.nil?
      (rtn.split("\n").collect {|l| l.split("=", 2)})
    else
      []
    end
  end

  def self.api_get(path, params)
    uri = sso_url
    uri.path+=path
    uri.query = URI.encode_www_form(params) if !params.nil?
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      parse_return(res.body)
    else
      []
    end

  end

  def self.api_post(path, params)
    uri = sso_url
    uri.path+=path
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPSuccess
      parse_return(res.body)
    else
      []
    end
  end

  def self.get_cookie_name
    rtn = api_get("/identity/getCookieNameForToken", nil).first
    if !rtn.nil?
      rtn[1]
    else
      false
    end
  end

  def self.parse_user_details(user_details)
    if !user_details.nil?
      user_details.inject [{},nil] do |acc, kv|
        m,attr_name = acc
        k,v = kv
        case k
        when "userdetails.attribute.name"
          [m,v]
        when "userdetails.attribute.value"
          m[attr_name] = (m.fetch(attr_name, [])+[v])
          [m,attr_name]
        when "userdetails.role"
          match = (/id=(.+?),/.match(v))
          m[:roles] = (m.fetch(:roles, [])+[match[1]]) if !match.nil?
          [m, nil]
        else
          [m, nil]
        end
      end.first
    else
      {}
    end
  end

  def self.valid_token?(token)
    rtn = api_post("/identity/isTokenValid", tokenid: token).first
    if !rtn.nil?
      rtn[1]=="true"
    else
      false
    end
  end

  def self.get_attributes(token)
    parse_user_details(api_post("/identity/attributes", subjectid: token))
  end

end
