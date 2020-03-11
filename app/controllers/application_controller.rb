class ApplicationController < ActionController::API
  respond_to :html, only: :home

  def home
    render html: File.read('app/views/application/home.html').html_safe
  end

  private

  def request_ip_address
    ip_address = request.remote_ip
    ip_address unless ip_address == '::1'
  end

  def request_user_agent
    request.user_agent
  end
end
