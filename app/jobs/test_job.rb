class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "TestJob is running with arguments: #{args.inspect}"
  end
end
