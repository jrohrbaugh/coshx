class ApplicationController < ActionController::Base
  protect_from_forgery

  contenteditable_filter "admin_signed_in?"

  helper_method :last_three_posts, :random_quote, :whereami, :contents, :latest_tweet

  around_filter :catch_exceptions

  def contents
    Content.all
  end

  def last_three_posts
    @last_three_posts ||= Post.published.limit(3)
  end

  def random_quote
    Quote.first(:order => "RANDOM()")
  end

  def whereami
     params[:controller].to_s + "/" + params[:action]
     #     controller.controller_name.to_s + "/" + controller.action_name
  end

  def latest_tweet

    if Rails.env.staging?
      @twitter_url = "SiteStagingTest"
    else
      @twitter_url = "coshxlabs"
    end

    if Rails.env.test?
      user = OpenStruct.new ({:screen_name => "test_user"})
      @latest_tweet = OpenStruct.new ({:user => user, :text => "This is a tweet", :id => 1, :created_at => Time.parse("2013-06-26 13:10:23 -0400")} )
    else
      begin
        @latest_tweet = Twitter.user_timeline(@twitter_url, :count => 1)[0]
      rescue => ex
        user = OpenStruct.new({:screen_name => "system_error"})
        @latest_tweet = OpenStruct.new ({:user => user, :text => "Error retrieving tweets: #{ex}", :id => 1, :created_at => Time.parse("2013-06-26 13:10:23 -0400")})
      end
    end
  end

  protected

    def render_page_not_found
      render template: 'errors/not_found'
    end

    def render_error
      render template: 'errors/505'
    end


    def catch_exceptions
      if Rails.env.production?
        begin
          yield
        rescue Exception => exception
          if exception.is_a?(ActiveRecord::RecordNotFound) || exception.is_a?(ActionController::RoutingError)
            render_page_not_found
          else
            render_error
          end
        end
      else
        yield
      end
    end

end
