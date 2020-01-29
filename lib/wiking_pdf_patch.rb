require_dependency 'redmine/export/pdf'

module WikingPDFPatch

    def self.prepended(base)
        base.send(:prepend, InstanceMethods)
        base.class_eval do
            unloadable

        end
    end

    module InstanceMethods

        def formatted_text(text)
            html = super(text)

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
