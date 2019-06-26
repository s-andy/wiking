require_dependency 'redmine/export/pdf'

module WikingPDFPatch

	def self.prepended(base)
        base.class_eval do
            unloadable
        end
    end

	def formatted_text(text)
		html = super
		
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
