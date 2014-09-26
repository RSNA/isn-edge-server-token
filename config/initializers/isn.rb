require File.join(Rails.root,'lib','sendemail-isn-1.0.jar')
require File.join(Rails.root,'lib','transfer-content-3.2.0-t1.jar')
require File.join(Rails.root,'lib','prep-content-3.2.0-t1.jar')
Java::org.rsna.isn.util.Environment.init("prep-content")
Java::org.rsna.isn.util.Environment.init("transfer-content")
Java::org.rsna.isn.util.Environment.init("send-mail")

