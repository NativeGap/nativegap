# frozen_string_literal: true

module Layouts
  module MozaicHelper
    def layouts_mozaic_body_class
      'myg myg-layout '\
      "#{class_hierarchy([params[:controller].split('/'), action_name])} "\
      "#{area(:body_class, '')}"
    end
  end
end
