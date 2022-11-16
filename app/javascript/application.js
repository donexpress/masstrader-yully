// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.cookie = "browser-tz" + "=" + Intl.DateTimeFormat().resolvedOptions().timeZone
