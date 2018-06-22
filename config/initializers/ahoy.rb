class Ahoy::Store < Ahoy::DatabaseStore
    def exclude?
        bot?
    end
end

# set to true for JavaScript tracking
Ahoy.api = false
