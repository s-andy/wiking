require_dependency 'user'

module WikingUserPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
            unloadable

            unless method_defined?(:nickname)
                def nickname
                    return @nickname if instance_variable_defined?(:@nickname)
                    @nickname = Setting.plugin_wiking['nickname_custom_field'].to_i > 0 ?
                                custom_field_value(Setting.plugin_wiking['nickname_custom_field']) : nil
                end
            end
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
