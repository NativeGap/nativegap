# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    turbolinks_animate 'fadein'
  end

  def language
    modalist
  end

  def notify
    modalist
  end
end
