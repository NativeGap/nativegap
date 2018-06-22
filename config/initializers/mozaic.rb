Mozaic.configure do |config|

    # Use Mozaic with Webpacker
    # config.es6 = true
    # Javascript asset directory
    config.javascripts = 'app/webpack/javascripts'
    # Stylesheet asset directory
    config.stylesheets = 'app/webpack/stylesheets'

    # Define Mozaic components
    config.define_component 'confirm'
    config.define_component 'footer'
    config.define_component 'layouts/google_analytics', tracking_id: Rails.application.credentials.google_analytics[:tracking_id]

end
