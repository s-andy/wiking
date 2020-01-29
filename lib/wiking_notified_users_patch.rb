module WikingNotifiedUsersPatch

    def self.prepended(base)
        base.send(:prepend, InstanceMethods)
        base.class_eval do
            unloadable

            has_many :mentions, :as => :mentioning, :inverse_of => :mentioning, :dependent => :delete_all
            has_many :mentioned_users, :through => :mentions, :source => :mentioned

        end
    end

    module InstanceMethods

        def notified_users
            if is_a?(Journal)
                notified = journalized.notified_users_without_mentioned_users
                if private_notes?
                    notified.reject!{ |user| !user.allowed_to?(:view_private_notes, journalized.project) }
                end
            else
                notified = super
            end
            mentioned = mentioned_users.to_a
            if mentioned.any?
                mentioned.reject!{ |user| !visible?(user) } if respond_to?(:visible?)
                notified += mentioned
                notified.uniq!
            end
            notified
        end

    end

end
