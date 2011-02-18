class AddUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email,               :null => false
      t.string :name
      t.string :type
      t.string :state,               :null => false, :default => 'not_valid'
      t.string :time_zone
      t.string :crypted_password,               :null => false
      t.string :password_salt,               :null => false
      t.string :persistence_token,               :null => false
      t.string :single_access_token,               :null => false
      t.string :perishable_token,               :null => false
      t.integer :login_count,               :null => false, :default => 0
      t.integer :failed_login_count,               :null => false, :default => 0
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      t.string :cim_id
      t.boolean :card_valid

      t.timestamps
    end
    add_index :users, :perishable_token
    add_index :users, :email
    add_index :users, :name
  end

  def self.down
    drop_table :users
  end
end
