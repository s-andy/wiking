require_dependency 'mailer'

module WikingMailerPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            class << self
                alias_method :deliver_issue_add_without_mentions, :deliver_issue_add
                alias_method :deliver_issue_add, :deliver_issue_add_with_mentions

                alias_method :deliver_issue_edit_without_mentions, :deliver_issue_edit
                alias_method :deliver_issue_edit, :deliver_issue_edit_with_mentions
            end
        end
    end

    module ClassMethods

        def deliver_issue_add_with_mentions(issue)
            begin
                view_context_class.new.textilizable(issue, :description, :force_notify => true)
                issue.mentioned_users.reload
            rescue
            end

            deliver_issue_add_without_mentions(issue)
        end

        def deliver_issue_edit_with_mentions(journal)
            if journal.notes?
                begin
                    view_context_class.new.textilizable(journal, :notes)
                    journal.mentioned_users.reload
                rescue
                end
            end

            deliver_issue_edit_without_mentions(journal)
        end

    end

    module InstanceMethods

        def mention(user, mention)
            subject_prefix = mention.project ? "[#{mention.project.name}] " : ''

            redmine_headers('Mentioning-Type' => mention.mentioning.class.name,
                            'Mentioning-Id'   => mention.mentioning.id)
            redmine_headers('Project'         => mention.project.identifier) if mention.project
            message_id(mention)

            @title = mention.title
            @url   = url_for(mention.url)
            @user  = user

            mail(:to            => user.mail,
                 :subject       => subject_prefix + l(:mail_subject_you_mentioned, :locale =>  user.language)) do |format|
                format.html { render('you_mentioned') }
                format.text { render('you_mentioned') }
            end
        end

    end

end
