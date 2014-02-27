ActiveRecord::ConnectionAdapters::PostgreSQLJdbcConnection.class_eval do
  def wait_for_notify(timeout = nil)
    Timeout.timeout(timeout) do
      loop do
        notifications = connection.get_notifications

        if notifications
          notifications.each do |notification|
            yield [notification.name, notification.pid, notification.parameter]
          end

          return true
        end
      end
    end
  rescue Timeout::Error
  end
end
