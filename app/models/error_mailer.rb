# ErrorMailer sends error messages to the admin.

class ErrorMailer < ActionMailer::Base

  # Delivers the error message. Recipient is defined by the ERRORS_EMAIL constant in config/initializers/settings.rb
  #
  # Parameters:
  # exception::  exception object
  # trace::      backtrace string
  # params::     controller params
  # request::    request object
  # sent_on::    timestamp
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
