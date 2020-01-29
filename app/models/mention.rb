class Mention < ActiveRecord::Base
    belongs_to :mentioned, :class_name => 'User'
    belongs_to :mentioning, :polymorphic => true

    before_save  :set_created_on
    after_create :send_notification

    def set_created_on
        if mentioning.respond_to?(:mentioning_date)
            self.created_on = mentioning.mentioning_date
        elsif mentioning.respond_to?(:updated_on)
            self.created_on = mentioning.updated_on
        elsif mentioning.respond_to?(:created_on)
            self.created_on = mentioning.created_on
        end
    end

    def send_notification
        if Setting.notified_events.include?('user_mentioned') &&
           %w(all only_my_events only_owner).include?(mentioned.mail_notification) &&
           title.present? && url.present? && created_on > 1.day.ago &&
           (!mentioning.respond_to?(:visible?) || mentioning.visible?(mentioned))
            return if mentioning.respond_to?(:notified_users) && mentioning.notified_users.include?(mentioned)
            return if mentioning.respond_to?(:notified_watchers) && mentioning.notified_watchers.include?(mentioned)
            Mailer.mention(self).deliver
        end
    rescue Exception => exception
        Rails.logger.error exception.message
    end

    def class_name
        @class_name ||= if mentioning.respond_to?(:mentioning_class)
            mentioning.mentioning_class
        elsif mentioning.respond_to?(:event_type)
            mentioning.event_type
        else
            mentioning.class.name.underscore
        end
    end

    def project
        @project ||= if mentioning.respond_to?(:mentioning_project)
            mentioning.mentioning_project
        elsif mentioning.respond_to?(:project)
            mentioning.project
        else
            nil
        end
    end

    def title
        @title ||= if mentioning.respond_to?(:mentioning_title)
            mentioning.mentioning_title
        elsif mentioning.respond_to?(:event_title)
            mentioning.event_title
        elsif mentioning.respond_to?(:title)
            mentioning.title
        elsif mentioning.respond_to?(:subject)
            mentioning.subject
        elsif mentioning.respond_to?(:name)
            mentioning.name
        else
            nil
        end
    end

    def url
        @url ||= if mentioning.respond_to?(:mentioning_url)
            mentioning.mentioning_url
        elsif mentioning.respond_to?(:event_url)
            mentioning.event_url
        elsif mentioning.respond_to?(:url)
            mentioning.url
        else
            nil
        end
    end

    def description
        @description ||= if mentioning.respond_to?(:mentioning_description)
            mentioning.mentioning_description
        elsif mentioning.respond_to?(:summary)
            mentioning.summary
        elsif mentioning.respond_to?(:event_description)
            mentioning.event_description
        elsif mentioning.respond_to?(:description)
            mentioning.description
        elsif mentioning.respond_to?(:text)
            mentioning.text
        else
            nil
        end
    end

    def author
        @author ||= if mentioning.respond_to?(:mentioning_author)
            mentioning.mentioning_author
        elsif mentioning.respond_to?(:event_author)
            mentioning.event_author
        elsif mentioning.respond_to?(:author)
            mentioning.author
        else
            nil
        end
    end

    def self.digest(object)
        connection.select_rows("SELECT mentioned_id " +
                               "FROM #{Mention.table_name} " +
                               "WHERE mentioning_type = '#{object.class.name}' AND mentioning_id = #{object.id} " +
                               "ORDER BY mentioned_id").flatten.uniq.join(',')
    end

end
