# frozen_string_literal: true

ActiveSupport.on_load(:active_support_test_case) do
  setup { ActionMailer::Base.deliveries.clear }
end
