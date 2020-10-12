module WikingNotifiablePatch

    def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
            unloadable

            class << self
                alias_method :all_without_wiking, :all
                alias_method :all, :all_with_wiking
            end
        end
    end

    module ClassMethods

        def all_with_wiking
            notifications = all_without_wiking
            notifications << Redmine::Notifiable.new('user_mentioned')
            notifications
        end

    end

end
