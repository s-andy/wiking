require_dependency 'user'

module WikingUserPatch

    def self.prepended(base)
        base.prepend(ClassMethods)
        base.class_eval do
            unloadable
        end
    end

    module ClassMethods

        def find(*args)
            if args.first && args.first.is_a?(String) && !args.first.match(%r{\A\d*\z})
                user = find_by_login(*args)
                if user.nil?
                    raise ActiveRecord::RecordNotFound, "Couldn't find User with login=#{args.first}"
                else
                    user
                end
            else
                super
            end
        end

    end

end
