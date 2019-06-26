module WikingNotifiablePatch

	def self.prepended(base)
        base.class_eval do
            unloadable
        end
    end

	def all
		notifications = super
		notifications << Redmine::Notifiable.new('user_mentioned')
        notifications
	end
end
