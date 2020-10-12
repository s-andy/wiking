class AddIndexOnUsersLogin < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        add_index :users, :login
    end

    def self.down
        remove_index :users, :login
    end

end
