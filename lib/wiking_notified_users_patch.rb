module WikingNotifiedUsersPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            has_many :mentions, :as => :mentioning, :inverse_of => :mentioning, :dependent => :delete_all
            has_many :mentioned_users, :through => :mentions, :source => :mentioned

            alias_method_chain :notified_users, :mentioned_users
        end
    end

    module InstanceMethods

        def notified_users_with_mentioned_users
            journalized.instance_variable_set(:@skip_mentioned_users, true) if is_a?(Journal)
            notified = notified_users_without_mentioned_users
            if !@skip_mentioned_users && (mentioned = mentioned_users.to_a).any?
                mentioned.reject!{ |user| !visible?(user) } if respond_to?(:visible?)
                notified += mentioned
                notified.uniq!
            end
            notified
        end

        def notification_to_be_sent?
            if is_a?(Issue)
                Setting.notified_events.include?('issue_added')
            elsif is_a?(Journal)
                Setting.notified_events.include?('issue_updated') || Setting.notified_events.include?('issue_note_added')
            else
                false
            end
        end

    end

end
