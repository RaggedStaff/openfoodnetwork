# frozen_string_literal: false

module CustomerAccountTransactions
  class DataLoaderService
    attr_reader :user, :enterprise

    def initialize(user:, enterprise:)
      @user = user
      @enterprise = enterprise
    end

    def customer_account_transactions
      return [] if enterprise_customer.nil?

      enterprise_customer.customer_account_transactions.order(id: :desc)
    end

    def available_credit
      enterprise_customer&.credit_balance || 0.00
    end

    private

    def enterprise_customer
      user.customers.find_by(enterprise:)
    end
  end
end
