class Api::SessionController < Api::ApiController
  def destroy
    current_user.sessions.where(uuid: params[:uuid]).destroy_all
    render json: {}, status: :no_content
  end

  def destroy_all
    current_user.sessions.where.not(uuid: @current_session.uuid).destroy_all
    render json: {}, status: :no_content
  end
end