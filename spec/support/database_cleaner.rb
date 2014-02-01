DatabaseCleaner.strategy = :transaction

module DatabaseCleanerHelpers
  def with_truncation
    DatabaseCleaner.strategy = :truncation
    yield
  ensure
    DatabaseCleaner.strategy = :transaction
  end
end

RSpec.configure do |config|
  config.include(DatabaseCleanerHelpers)

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
