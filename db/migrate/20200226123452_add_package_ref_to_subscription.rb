class AddPackageRefToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscriptions, :package, foreign_key: true
  end
end
