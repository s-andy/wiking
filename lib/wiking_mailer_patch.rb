require_dependency 'mailer'

module WikingMailerPatch

    def self.prepended(base)
        base.prepend(ClassMethods)
        base.send(:prepend, InstanceMethods)
        base.class_eval do
            unloadable

            # class << self
            #     alias_method_chain :deliver_issue_add,  :mentions
            #     alias_method_chain :deliver_issue_edit, :mentions
            # end
        end
    end

    module ClassMethods

        def deliver_issue_add(issue)
            begin
                view_context_class.new.textilizable(issue, :description)
            rescue
            end

            super(issue)
        end

        def deliver_issue_edit(journal)
            if journal.notes?
                begin
                    view_context_class.new.textilizable(journal, :notes)
                rescue
                end
            end

            super(journal)
        end

    end

    module InstanceMethods

        def mention(mention)
            subject_prefix = mention.project ? "[#{mention.project.name}] " : ''

            redmine_headers('Mentioning-Type' => mention.mentioning.class.name,
                            'Mentioning-Id'   => mention.mentioning.id)
            redmine_headers('Project'         => mention.project.identifier) if mention.project
            message_id(mention)

            @title = mention.title
            @url   = url_for(mention.url)
            @user  = mention.mentioned

            mail(:to            => mention.mentioned.mail,
                 :subject       => subject_prefix + l(:mail_subject_you_mentioned, :locale =>  mention.mentioned.language)) do |format|
                format.html { render('you_mentioned') }
                format.text { render('you_mentioned') }
            end
        end

    end

end
