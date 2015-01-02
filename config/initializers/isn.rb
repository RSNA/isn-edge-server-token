require 'net/http'

if !ENV['ISN_BUILD']
  Java::org.rsna.isn.util.Environment.init("token")
end
if ENV["RAILS_ENV"] == "production" and !ENV['ISN_BUILD']

  openam_url = URI(ENV["OPENAM_URL"])
  puts "Waiting for OpenAM startup #{openam_url}"

  tries = 0
  timeout = 8
  openam_ready = false

  while !openam_ready and (tries < timeout) do
    res = Net::HTTP.get_response(openam_url)
    if res.code == 404
      tries+=1
      sleep((2.0 ** tries) - 1.0)
    else
      openam_ready = true
      puts "OpenAM started"
    end
  end
  if openam_ready
    puts "Priming OpenAM agent"
    agent_url = URI(ENV["OPENAM_URL"])
    agent_url.path = "/agentapp/"
    Net::HTTP.get_response(openam_url).body
  else
    puts "OpenAM startup wait timeout"
  end

end
