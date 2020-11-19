
# Rails.application.config.session_store :cookie_store,    
#       secure: Rails.env.production?,  # secure when in production
#       httponly: true,
#       expire_after: 1.hours

Rails.application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 1.hours
