require_dependency 'redmine/wiki_formatting/textile/helper'

module WikingWikiHelperPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method :wikitoolbar_for, :wikitoolbar_with_wiking_for
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def wikitoolbar_with_wiking_for(field_id)
            unless @heads_for_wiki_formatter_included
                content_for :header_tags do
                    wiki_heads = ''
                    wiki_heads << javascript_include_tag('jstoolbar/jstoolbar-textile.min')
                    wiki_heads << javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}")
                    wiki_heads << stylesheet_link_tag('jstoolbar')
                    wiki_heads.html_safe
                end
                @heads_for_wiki_formatter_included = true
            end

            unless @wiking_heads_for_wiki_formatter_included
                content_for :header_tags do
                    javascript_include_tag('wiking', :plugin => 'wiking')
                end
                @wiking_heads_for_wiki_formatter_included = true
            end

            if File.exists?(File.join(Rails.root, 'public/help', current_language.to_s.downcase, 'wiki_syntax_textile.html'))
                help_url = "#{Redmine::Utils.relative_url_root}/help/#{current_language.to_s.downcase}/wiki_syntax_textile.html"
            else
                help_url = "#{Redmine::Utils.relative_url_root}/help/#{current_language.to_s.downcase}/wiki_syntax.html"
            end

            if File.exists?(File.join(Rails.root, 'plugins/wiking/assets/help/', current_language.to_s.downcase, 'wiki_syntax.html'))
                wiking_url = "#{Redmine::Utils.relative_url_root}/plugin_assets/wiking/help/#{current_language.to_s.downcase}/wiki_syntax.html"
            else
                wiking_url = "#{Redmine::Utils.relative_url_root}/plugin_assets/wiking/help/en/wiki_syntax.html"
            end

            js_code = "var wikiToolbar = new jsToolBar(document.getElementById('#{field_id}'));"
            js_code << "wikiToolbar.setMoreLink('#{escape_javascript(wiking_url)}');"
            js_code << "wikiToolbar.setHelpLink('#{escape_javascript(help_url)}');"
            js_code << "wikiToolbar.draw();"

            javascript_tag(js_code)
        end

    end

end
