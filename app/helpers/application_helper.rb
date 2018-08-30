# frozen_string_literal: true

module ApplicationHelper
  # Returns class hierarchy in a string
  # e.g.: class_hierarchy([params[:controller].split('/'), action_name])
  def class_hierarchy(hierarchy = [], delimiter: ' ')
    hierarchy.join(delimiter)
  end

  def required_confirmation_in_days
    7 - (Date.today - current_user.created_at.to_date).to_i
  end

  def required_confirmation_in_days_string
    "#{required_confirmation_in_days} "\
    "#{t('mozaic._confirm.day').pluralize(required_confirmation_in_days)}"
  end
end
