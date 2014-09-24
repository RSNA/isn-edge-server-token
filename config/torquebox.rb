TorqueBox.configure do
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
