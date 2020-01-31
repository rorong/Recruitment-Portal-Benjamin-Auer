class AddStripeIdToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :stripe_id, :string
  end
end
