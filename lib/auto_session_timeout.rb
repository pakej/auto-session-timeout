module AutoSessionTimeout
  
  def self.included(controller)
    controller.extend ClassMethods
    controller.hide_action :render_auto_session_timeout
  end
  
  module ClassMethods
    def auto_session_timeout(seconds=nil)
      prepend_before_filter do |c|
        if c.session[:auto_session_expires_at] && c.session[:auto_session_expires_at] < Time.now
          c.send :reset_session
        else
          unless c.request.original_url.start_with?(c.send(:active_url))
            offset = seconds || (current_user.respond_to?(:auto_timeout) ? current_user.auto_timeout : nil)
            c.session[:auto_session_expires_at] = Time.now + offset if offset && offset > 0
          end
        end
      end
    end
    
    def auto_session_timeout_actions
      define_method(:active)  { render_session_status }
      define_method(:timeout) { render_session_timeout }
    end
  end
  
  def render_session_status(options={})
    devise_model  = options[:devise_model]  || "user"
    devise_model  = eval("current_#{devise_model}")     
    # clear etags to prevent caching
    response.headers["Etag"] = ""  
    render text: !!devise_model, status: 200
  end
  
  def render_session_timeout(options={})
    path          = options[:path]          || "/login"
    flash_name    = options[:flash_name]    || "notice"
    flash_message = options[:flash_message] || "Your session has timed out."

    eval("flash[:#{flash_name}] = \"#{flash_message}\"")
    redirect_to path    
  end
  
end

ActionController::Base.send :include, AutoSessionTimeout
