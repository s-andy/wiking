require_dependency 'journal'

module WikingJournalPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
        end
    end

    module InstanceMethods

        def visible?(user = nil)
            journalized.visible?(user)
        end

    end

end
