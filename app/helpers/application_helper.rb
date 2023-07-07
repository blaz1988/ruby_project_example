# frozen_string_literal: true

module ApplicationHelper
  def display_flash_error
    return unless flash.now[:error]

    content_tag(:div, flash.now[:error], class: 'alert alert-danger')
  end

  def display_notice
    return unless notice

    content_tag(:div, class: 'alert alert-success') do
      notice
    end
  end
end
