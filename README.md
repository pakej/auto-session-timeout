# auto-session-timeout (with devise)

Provides automatic session timeout in a Rails application. Very easy
to install and configure. Have you ever wanted to force your users
off your app if they go idle for a certain period of time? Many
online banking sites use this technique. If your app is used on any
kind of public computer system, this plugin is a necessity.

## Requirements



## Installation

Add this line to your application's Gemfile:

    gem 'auto-session-timeout', :git => 'https://github.com/zaimramlan/auto-session-timeout.git'

And then execute:

    $ bundle install

## Usage

After installing, tell your application controller to use auto timeout:

    class ApplicationController < ActionController::Base
      auto_session_timeout 1.hour
      ...
    end

You will also need to insert this line inside the body tags in your
views. The easiest way to do this is to insert it once inside your
default or application-wide layout:

    <body>
      ...
      <%= auto_session_timeout_js %>
    </body>

You need to setup two actions: one to return the session status and
another that runs when the session times out. You can use the default
actions included with the plugin by inserting this line in your target
controller (most likely your user or session controller):

    class SessionsController < ApplicationController
      auto_session_timeout_actions
    end

To customize the default actions, simply override them. You can call
the render_session_status and render_session_timeout methods to use
the default implementation from the plugin or you can define the actions 
entirely with your own custom code:

    class SessionsController < ApplicationController
      def active
        render_session_status
        # or do something when session is still active
      end
      
      def timeout
        render_session_timeout
        # or do something when session expires
      end
    end

In any of these cases, make sure to properly map the actions in your routes.rb file:
  
  devise_scope :admin do
    match 'active'  => 'admins/sessions#active',  via: :get
    match 'timeout' => 'admins/sessions#timeout', via: :get
  end

You're done! Enjoy watching your sessions automatically timeout.

## Additional Configuration

By default, the JavaScript code:
- checks the server every **60 seconds** for active sessions. 
- loads a refresher script to refresh rails' authenticity token every **60 seconds**, if the User (or your devise_model name) is not logged in.
- displays development logs in the console.
- recognizes your devise_model name as **User**

If you prefer that to have more flexibility, the following code:
- checks the server every **15 seconds** for active sessions. 
- refresh rails' authenticity token every **25 seconds**, if the User (or your devise_model name) is not logged in.
- hides development logs from the console.
- recognizes your devise_model name as **manager** 

    <html>
      <head>...</head>
      <body>
        ...
        <%= auto_session_timeout_js frequency: 20, #in seconds
                                    refresh_rate: 60, #in seconds
                                    verbosity: 0, # 2 - display all logs, 1 - display some logs, 0 - hides all logs
                                    devise_model: 'manager' %>
      </body>
    </html>

    class SessionsController < ApplicationController
      def active
        # render_session_status devise_model: '<your_devise_model_name>'
        # by default, devise_model: 'user'
        render_session_status devise_model: 'admin'
      end
      
      def timeout
        # render_session_timeout path: <path_to_redirect_to>, '<flash_name>', '<flash_message>'
        # by default, 
        # path:           '/login'
        # flash_name:     'notice'
        # flash_message:  'Your session has timed out.'
        render_session_timeout path: new_admin_session_path, flash_name: 'alert', flash_message: 'Session expired.'
      end
    end

## Resources

* Original Repository: http://github.com/pelargir/auto-session-timeout/
* Blog: http://www.matthewbass.com
* Author: Matthew Bass
