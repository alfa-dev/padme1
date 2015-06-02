class PadController < ApplicationController

  def show

    pad = Pad.find_by(name: params[:name])

    if pad.nil?
      @pad = Pad.new
    else
      @pad = pad
    end
  end

  def create
    @pad = Pad.where(name: params[:pad][:name]).first_or_create
    @pad.name    = params[:pad][:name]
    @pad.content = params[:pad][:content]
    
    if @pad.content.empty?
      @pad.destroy!
    else
      @pad.save!
    end
    
    redirect_to :back
  end

end
