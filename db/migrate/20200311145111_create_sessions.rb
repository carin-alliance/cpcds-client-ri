class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.string :patient_key
      t.string :patient_id
      t.string :token
      t.string :token_expiration
      t.string :server_url
      t.string :auth_url

      t.timestamps
    end
  end
end
