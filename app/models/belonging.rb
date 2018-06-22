class Belonging < ApplicationRecord

    acts_as_list :belonger

    belongs_to :belonger, polymorphic: true
    belongs_to :belongable, polymorphic: true

end
