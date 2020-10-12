require_dependency 'redmine/export/pdf'

module WikingPDFPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :formatted_text_without_wiking, :formatted_text
            alias_method :formatted_text, :formatted_text_with_wiking
        end
    end

    module InstanceMethods

        def formatted_text_with_wiking(text)
            html = formatted_text_without_wiking(text)

            html.gsub!(%r{<span class="wiking (marker|smiley) [^"]+" title="([^"]+)"></span>}) do |match|
                type, title = $1, $2
                case type
                when 'marker'
                    '{' + title + '}'
                else
                    title
                end
            end

            html
        end

    end

end
