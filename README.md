# auto-session-timeout (with devise)

Provides automatic session timeout in a Rails application. Very easy
to install and configure. Have you ever wanted to force your users
off your app if they go idle for a certain period of time? Many
online banking sites use this technique. If your app is used on any
kind of public computer system, this plugin is a necessity.

## Dependencies

- [jquery-periodicalupdater](https://github.com/RobertFischer/JQuery-PeriodicalUpdater) 
Simply put the js files into your `asset/javascript` folder

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
  
    # you can replace 'user' with your devise model's name
    devise_scope :user do
      match 'active'  => 'users/sessions#active',  via: :get
      match 'timeout' => 'users/sessions#timeout', via: :get
    end

You're done! Enjoy watching your sessions automatically timeout.

## Additional Configuration
You can specify the following parameters to further customize `auto_session_timeout_js`:

|    Options    |                            Function                             | Value Type  |                             Example                               | Default Value   |
|:------------: |:-------------------------------------------------------------:  |:----------: |:---------------------------------------------------------------:  |:-------------:  |
|   verbosity   |        Displays logs in the browser's developer console         |   Integer   | 2 - Display all logs, 1 - Display some logs,  0 - Hides all logs  |       2         |
|   frequency   |     Frequency to check the server for any active sessions       |   Integer   |                         60 - In Seconds                           |       60        |
| refresh_rate  | Rate of refresher script to refresh rails' authenticity token   |   Integer   |                         90 - In Seconds                           |       60        |
| devise_model  |                   Name of your devise_model                     |   String    |                             'admin'                               |     'user'      |

If you prefer that to have more flexibility, the following code:
- hides development logs from the console.
- checks the server every **20 seconds** for active sessions. 
- refresh rails' authenticity token every **50 seconds**, if the *manager* is not logged in.
- recognizes your `devise_model` name as **manager** 

Simply modify the following code.

    <html>
      <head>...</head>
      <body>
        ...
        <%= auto_session_timeout_js verbosity: 0,     # 2 - display all logs, 1 - display some logs, 0 - hides all logs
                                    frequency: 20,    #in seconds
                                    refresh_rate: 50, #in seconds
                                    devise_model: 'manager' %>
      </body>
    </html>

Also, you can call the `render_session_status` and `render_session_timeout` methods to use the default implementation from the plugin
with your own parameters as follows:

|         Method          |    Options      |                           Function                            | Value Type  |       Example       |         Default Value           |
|:----------------------: |:-------------:  |:------------------------------------------------------------: |:----------: |:------------------: |:-----------------------------:  |
|  render_session_status  |  devise_model   |                   Name of your devise_model                   |   String    |       'admin'       |             "user"              |
| render_session_timeout  |      path       |         Path to redirect to, when the session expires         |   String    |    "/user_login"    |            "/login"             |
|                         |   flash_name    |                      Name of your flash                       |   String    |       "alert"       |            "notice"             |
|                         | flash_message   | Message to be shown through flash when the session timed out  |   String    | "Session Expired."  | "Your session has timed out."   |

The following is an example usage of the parameters.

    class SessionsController < ApplicationController
      def active
        # render_session_status devise_model: '<your_devise_model_name>'
        render_session_status devise_model: 'admin'
      end
      
      def timeout
        # render_session_timeout path: <path_to_redirect_to>, '<flash_name>', '<flash_message>'
        render_session_timeout path: new_admin_session_path, flash_name: 'alert', flash_message: 'Session expired.'
      end
    end

## Additional Information

**TL;DR**: It is best to keep the refresher script, to refresh at the same rate as the
session times out.  
(i.e. if `auto_session_timeout 1.minute`, so does `refresher_rate: 60 #in seconds`)

If we set the `auto_session_timeout` in `application_controller.rb`, regardless of an existing session,
it will still 'expire' at the time set. This will expire the rails `authenticity_token` as well. Therefore,
if we were to re-login without refreshing the `authenticity_token`, it will render an error page after
submitting the login credentials.

If we auto refresh the `authenticity_token`, the re-login process should submit with no problems.

## Resources

* Original Repository: http://github.com/pelargir/auto-session-timeout/
* Blog: http://www.matthewbass.com
* Author: Matthew Bass
