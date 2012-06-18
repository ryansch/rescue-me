require "rescue_me/version"
require 'net/http'
require 'net/smtp'

# Example:
# begin
#   method_here
# rescue RescueMe.net_http_errors => error
#   notify_airbrake error
# end

module RescueMe
  extend self

  def net_http_errors(opts = {})
    err = [Timeout::Error,
            Errno::EINVAL,
            Errno::ECONNRESET,
            Errno::EPIPE,
            Errno::ECONNABORTED,
            Errno::EBADF,
            EOFError,
            SocketError,
            Net::HTTPBadResponse,
            Net::HTTPHeaderSyntaxError,
            Net::ProtocolError]

    err << Net::HTTP::Persistent::Error if defined? Net::HTTP::Persistent::Error
    err << OpenSSL::SSL::SSLError if defined? OpenSSL::SSL::SSLError

    err
  end

  def active_resource_errors(opts = {})
    err = net_http_errors(opts)

    if defined? ActiveResource::ConnectionError
      err.delete(Timeout::Error)
      err += [ActiveResource::TimeoutError, ActiveResource::SSLError, ActiveResource::ServerError]
    end

    err
  end

  def net_smtp_server_errors(opts = {})
    with_auth = opts.fetch(:with_auth, true)

    err = [Timeout::Error,
      IOError,
      Net::SMTPUnknownError,
      Net::SMTPServerBusy]

    err << Net::SMTPAuthenticationError if with_auth

    err
  end

  def net_smtp_client_errors(opts = {})
    with_auth = opts.fetch(:with_auth, false)

    err = [Net::SMTPFatalError,
      Net::SMTPSyntaxError]

    err << Net::SMTPAuthenticationError if with_auth

    err
  end

  def net_smtp_errors(opts = {})
    net_smtp_server_errors + net_smtp_client_errors
  end

  %w[net_http active_resource net_smtp_server net_smtp_client net_smtp].each do |type|
    define_method(type + '_errors_with') do |arg, *opts|
      opts = opts.first || Hash.new
      errors_with((type + '_errors').to_sym, arg, opts)
    end
  end

  private
  def errors_with(errors_sym, arg, opts = {})
    if arg.kind_of? Array
      ary = arg
    elsif arg.is_a?(Class) && arg.ancestors.include?(Exception)
      ary = [arg]
    elsif arg.respond_to?(:each)
      ary = []
      arg.each {|a| ary << a }
    else
      raise ArgumentError, "Must be an Array, Exception, or respond to each."
    end

    self.send(errors_sym, opts) + ary
  end
end

