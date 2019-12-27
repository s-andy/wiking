require_dependency 'journal'

module WikingJournalPatch

    def self.included(base)
        base.send(:include, VisibleMethod) unless base.method_defined?(:visible?)
        base.class_eval do
            unloadable
        end
    end

    module VisibleMethod

        def visible?(user = nil)
            journalized.visible?(user) && (!private_notes? || user.allowed_to?(:view_private_notes, project))
        end

    end

end
