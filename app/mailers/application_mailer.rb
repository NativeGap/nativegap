class ApplicationMailer < ActionMailer::Base
    default from: Settings.mailgun.emails.with
    layout 'mailer'
end
