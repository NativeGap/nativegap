# frozen_string_literal: true

module ApplicationHelper
  # Returns class hierarchy in a string
  # e.g.: class_hierarchy([params[:controller].split('/'), action_name])
  def class_hierarchy(hierarchy = [], delimiter: ' ')
    hierarchy.map(&:inspect).join(delimiter).delete('",[]')
  end
end
