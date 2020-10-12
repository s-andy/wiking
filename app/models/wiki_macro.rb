require 'cgi'

class WikiMacro < ActiveRecord::Base
    include ERB::Util

    NAME_MAX_LENGTH = 30

    validates_presence_of :name, :description, :content
    validates_length_of :name, :maximum => NAME_MAX_LENGTH
    validates_format_of :name, :with => %r{\A[a-z0-9_]+\z}, :allow_blank => true

    validate :validate_name

    attr_protected :id if Rails::VERSION::MAJOR < 5

    MACRO_ARGUMENT_RE = %r{%(url)?(?:\{([^{=}]*)\}|\[([0-9]*)\]|\((\**)\))}

    def to_s
        "{{#{name}}}"
    end

    def exec(args, text, params)
        self.content.gsub(MACRO_ARGUMENT_RE) do |match|
            escape = $1
            if $2
                param = $2.downcase.to_sym
                params.has_key?(param) ? self.escape(params[param], escape) : ''
            elsif $3
                index = $3.to_i
                (index > 0 && index <= args.size) ? self.escape(args[index-1], escape) : ''
            else
                self.escape(text, escape)
            end
        end.html_safe
    end

    def escape(value, type)
        type.downcase! if type.respond_to?(:downcase!)
        case type
        when 'url'
            value = CGI.escape(value)
        end
        h(value)
    end

    def register!
        wiki_macro  = self
        macro_desc  = self.description
        macro_name  = self.name.to_sym
        Redmine::WikiFormatting::Macros.register do
            desc macro_desc
            macro macro_name do |obj, args, text|
                unnamed, named = WikiMacro.extract_macro_arguments(args)
                wiki_macro.reload.exec(unnamed, text, named)
            end
        end
    end

    def update_description!
        Redmine::WikiFormatting::Macros.available_macros[name.to_sym][:desc] = description
    end

    def unregister!
        self.class.unregister!(self.name)
    end

    def self.extract_macro_arguments(args)
        named = {}
        unnamed = []
        args.each do |arg|
            if arg =~ %r{\A([^{=}]+)=(?:(['"])([^\2]*)\2|(.*))\z}
                named[$1.downcase.to_sym] = $2 ? $3 : $4
            else
                arg.gsub!(%r{\A(['"])(.*)\1\z}, '\\2')
                unnamed << arg
            end
        end
        [ unnamed, named ]
    end

    def self.unregister!(name)
        Redmine::WikiFormatting::Macros.available_macros.delete(name.to_sym)
        Redmine::WikiFormatting::Macros::Definitions.send(:remove_method, "macro_#{name.downcase}")
    end

    def self.register_all!
        all.each do |macro|
            macro.register!
        end
    end

private

    def validate_name
        if name_changed?
            if Redmine::WikiFormatting::Macros.available_macros.has_key?(name.to_sym) ||
               Redmine::WikiFormatting::Macros::Definitions.method_defined?("macro_#{name.downcase}")
                errors.add(:name, :taken)
            end
        end
    end

end
