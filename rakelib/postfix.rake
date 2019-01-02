# Postfix configuration
# http://www.postfix.org/documentation.html

require 'date'
require 'net/smtp'
require 'securerandom'

namespace 'postfix' do
  desc 'Configure Postfix for SMTP relay'
  task :configure do
    case RUBY_PLATFORM
    when /darwin/
      # Add SMTP credentials to /etc/postfix/sasl_passwd
      
      # Add sender relay to /etc/postfix/sender_relay
      
      # Set local aliases
      
      # Set generic maps for outgoing mail
    
      # Set configuration for SMTP relay
      
      # Configure launchd
      
      # Start Postfix
      
      # Send test message
    end
  end
  
  task :sendtest do
    sender = 'robot@example.com'
    recipient = 'user@example.com'
    msg = <<-END_OF_MESSAGE
From: Andrew Carter <#{sender}>
To: Andrew Carter <#{recipient}>
Subject: Postfix test message
Date: #{DateTime.now.rfc2822}
Message-Id: <#{SecureRandom.uuid}@flipboard.com>

This is a test message send via Postfix SMTP relay.
    END_OF_MESSAGE
    
    Net::SMTP.start() do |smtp|
      smtp.send_message msg, recipient, recipient
    end
  end
end
