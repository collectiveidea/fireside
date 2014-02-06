class AccountsController < ApplicationController
  def show
    # Fireside's initial commit time
    @timestamp = Time.utc(2014, 1, 23, 17, 23, 55).in_time_zone
    @time_zone = ActiveSupport::TimeZone.find_tzinfo(ENV["TIME_ZONE"]).name
  end
end
