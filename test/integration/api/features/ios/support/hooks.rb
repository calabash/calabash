Before do
  unless $_started_app
    cal.ensure_app_installed
    cal.start_app

    $_started_app = true
  end
end

# Cleanup
After do
  if cal.keyboard_visible?
    cal.tap_keyboard_action_key
  end
end