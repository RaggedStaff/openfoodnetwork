# frozen_string_literal: true

module CustomerCredit
  extend ActiveSupport::Concern

  def calculate_credit(order)
    order.payments.incomplete.customer_credit.sum(:amount)
  end
end
