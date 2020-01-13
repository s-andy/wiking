module WikingNotifiablePatch

    def self.prepended(base)
        base.prepend(ClassMethods)
        base.class_eval do
            unloadable

        end
    end

    module ClassMethods

        def all
            notifications = super
            notifications << Redmine::Notifiable.new('user_mentioned')
            notifications
        end

    end

end
