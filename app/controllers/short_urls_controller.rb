class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    short_urls = ShortUrl.ordered.limit(100)

    render json: { urls: short_urls.each.map { |short_url| short_url.public_attributes } }, status: :ok
  end

  def create
    short_url = ShortUrl.new(short_url_params)

    if short_url.save
      UpdateTitleJob.perform_later(short_url.id)
      render json: { short_code: short_url.short_code }, status: :ok
    else
      errors = [I18n.t("errors.messages.invalid_full_url"), short_url.errors]
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    short_url = ShortUrl.find_by(short_code: params[:id])

    if short_url
      short_url.increment!(:click_count)
      redirect_to short_url.full_url
    else
      render file: "#{Rails.root}/public/404.html",  layout: false, status: :not_found
    end
  end

  private
  
  def short_url_params
    params.permit(
      :full_url,
    )
  end

end
