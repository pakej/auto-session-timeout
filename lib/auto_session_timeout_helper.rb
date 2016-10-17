module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency    = options[:frequency]    || 60
    verbosity    = options[:verbosity]    || 2
    refresh_rate = options[:refresh_rate] || 60
    devise_model = options[:devise_model] || "user"
    devise_model = eval("current_#{devise_model}")

    if devise_model.present?
      checker_js(frequency, verbosity)
    else
      refresher_js(refresh_rate)
    end
  end

  def checker_js(frequency, verbosity)
    code = <<JS
if (typeof(Ajax) != 'undefined') {
  new Ajax.PeriodicalUpdater('', '/active', {frequency:#{frequency}, verbose:#{verbosity}, method:'get', onSuccess: function(e) {
    if (e.responseText == 'false') window.location.href = '/timeout';
  }});
}else if(typeof(jQuery) != 'undefined'){
  function PeriodicalQuery() {
    $.ajax({
      url: '/active',
      success: function(data) {
        if(data == 'false'){
          window.location.href = '/timeout';
        }
      }
    });
    setTimeout(PeriodicalQuery, (#{frequency} * 1000));
  }
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
} else {
  $.PeriodicalUpdater('/active', {minTimeout:#{frequency * 1000}, multiplier:0, method:'get', verbose:#{verbosity}}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false')
      window.location.href = '/timeout';
  });
}
JS
    javascript_tag(code)
  end

  def refresher_js(refresh_rate)
    code = <<JS
setInterval(function(){ location.reload(); }, (#{refresh_rate} * 1000))
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper