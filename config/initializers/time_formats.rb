ActiveSupport::TimeWithZone.class_eval do
  def as_json(*)
    strftime("%Y/%m/%d %H:%M:%S %z")
  end
end
