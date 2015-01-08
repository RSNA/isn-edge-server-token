require 'sso'

if !ENV['ISN_BUILD']
  Java::org.rsna.isn.util.Environment.init("token")
end
