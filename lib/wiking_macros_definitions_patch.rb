require_dependency 'redmine/wiki_formatting/macros'

module WikingMacrosDefinitionsPatch

    def self.prepended(base)
        base.class_eval do
            unloadable
        end
    end

	def macro_exists?(name)
		exists = super(name)
		unless exists
            if macro = WikiMacro.find_by_name(name)
                macro.register!
                exists = true
            end
        end
        exists
	end

	def exec_macro(*args)
        method_name = "macro_#{args[0].downcase}"
        unless respond_to?(method_name)
            macro = WikiMacro.find_by_name(args[0])
            macro.register! if macro
        end
        if method_name == 'macro_macro_list'
            WikiMacro.all.each do |macro|
                macro.register! unless Redmine::WikiFormatting::Macros.available_macros.has_key?(macro.name.to_sym)
            end
        end
		super(*args)
    end
end
