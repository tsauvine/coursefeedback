class ErrorMailer < ActionMailer::Base

  def snapshot(exception, trace, params, request, sent_on = Time.now)
    @recipients         = ERRORS_EMAIL
    @from               = ERRORS_EMAIL
    @subject            = "[Error] PalauteProto exception in #{request.env['REQUEST_URI']}"
    @sent_on            = sent_on
    @body["exception"]  = exception
    @body["trace"]      = trace
    @body["params"]     = params
    @body["request"]    = request
    @body["env"]        = request.env
  end

end
