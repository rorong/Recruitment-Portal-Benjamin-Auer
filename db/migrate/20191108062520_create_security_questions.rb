class CreateSecurityQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :security_questions do |t|
      t.text  :question
      t.integer :user_id

      t.timestamps
    end
  end
end
