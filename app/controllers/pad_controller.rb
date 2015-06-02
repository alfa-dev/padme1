class PadController < ApplicationController

  def create
    @pad = Pad.where(name: params[:id]).first_or_create
  end

end
