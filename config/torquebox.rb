TorqueBox.configure do

  authentication :default, :domain => 'AMRealm'

  web do
    context "/"
  end

  ruby do
    version "2.0"
  end

  environment do
    RAILS_ENV 'production'
  end
end
