class ConversationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  def index
    redirect_to received_person_messages_path(:person_id => @current_user.id)
  end

  def received
    params[:page] = 1 unless request.xhr?
    @conversations = @current_community.conversations.for_person(@current_user)
      .order("last_message_at DESC")
      .paginate(per_page: 15, page: params[:page])
    request.xhr? ? (render :partial => "additional_messages") : (render :action => :index)
  end

  def show
    @conversation = @current_community.conversations.for_person(@current_user).find_by_id(params[:id])

    if @conversation.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to root
    end

    @current_user.read(@conversation) unless @conversation.read_by?(@current_user)
    @other_party = @conversation.other_party(@current_user)
  end
end
