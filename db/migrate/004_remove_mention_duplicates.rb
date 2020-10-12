class RemoveMentionDuplicates < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        CustomField.connection.delete("DELETE #{Mention.table_name} " +
                                      "FROM #{Mention.table_name} " +
                                      "LEFT JOIN(SELECT MIN(id) AS first_id, mentioning_type, mentioning_id, mentioned_id " +
                                                "FROM #{Mention.table_name} " +
                                                "GROUP BY mentioning_type, mentioning_id, mentioned_id) duplicates " +
                                           "ON #{Mention.table_name}.id = duplicates.first_id AND #{Mention.table_name}.mentioning_type = duplicates.mentioning_type AND " +
                                              "#{Mention.table_name}.mentioning_id = duplicates.mentioning_id AND #{Mention.table_name}.mentioned_id = duplicates.mentioned_id " +
                                      "WHERE duplicates.first_id IS NULL")
    end

end
