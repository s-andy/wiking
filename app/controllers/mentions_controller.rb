class MentionsController < ApplicationController
    include ApplicationHelper

    before_action :find_user,               :only => :index
    before_action :find_object_and_project, :only => :autocomplete

    def index
        count = 0
        @offset = 0
        scope = Mention
        if params[:offset]
            offset = params[:offset].to_i
            scope = scope.offset(offset).limit(2**32)
            @prev_offset = @offset = offset
        end
        if params[:next_offset] && params[:next_offset].to_i > 0
            @next_offset = params[:next_offset].to_i
        elsif @offset > 0
            @next_offset = 0
        end
        mentions = []
        scope.where(:mentioned_id => @user.id)
             .order("created_on DESC").each do |mention|
            if mention.title.present? && (!mention.mentioning.respond_to?(:visible?) || mention.mentioning.visible?)
                mentions << mention
                count += 1
            end
            @offset += 1
            break if count == 50
        end
        @mentions_by_day = mentions.group_by do |mention|
            mention.created_on.to_date
        end
    end

    def autocomplete
        if params[:q].blank?
            if @object.is_a?(Issue)
                @users = []
                @users << @object.author if @object.author
                @users += @object.assigned_to.is_a?(Group) ? @object.assigned_to.users : [ @object.assigned_to ] if @object.assigned_to
                @users += @object.journals.collect{ |journal| journal.user }
                @users.sort!.uniq!
            elsif @object.is_a?(Message)
                @users = []
                @users << @object.author
                @users += @object.children.collect{ |reply| reply.author }
                @users.sort!.uniq!
            elsif @object.is_a?(News)
                @users = []
                @users << @object.author
                @users += @object.comments.collect{ |comment| comment.author }
                @users.sort!.uniq!
            elsif @project
                @users = @project.members.sort.uniq.collect{ |member| member.user }
            else
                @users = []
            end
        end
        if @users.nil?
            conditions = %w(login firstname lastname).map{ |column| "LOWER(#{User.table_name}.#{column}) LIKE LOWER(:q)" }
            conditions << "#{User.table_name}.id LIKE :q" if params[:c] == '#'
            scope = User.active
            scope = scope.visible if scope.respond_to?(:visible)
            @users = scope.sorted.where(conditions.join(' OR '), { :q => "#{params[:q]}%" }).limit(10)
        end
        render(:layout => false, :locals => { :c => params[:c] })
    end

private

    # A copy of #find_user in UsersController
    def find_user
        if params[:id] == 'current'
            require_login || return
            @user = User.current
        else
            @user = User.find(params[:id])
        end
    rescue ActiveRecord::RecordNotFound
        render_404
    end

    def find_object_and_project
        if params[:object_type] && params[:object_id]
            klass = Object.const_get(params[:object_type].camelcase) rescue nil
            if klass
                @object = klass.find(params[:object_id])
                raise Unauthorized if @object && @object.respond_to?(:visible?) && !@object.visible?
            end
        end
        if params[:project_id]
            @project = Project.visible.find_by_param(params[:project_id])
        end
    end
end
