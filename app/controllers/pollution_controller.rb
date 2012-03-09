class PollutionController < ApplicationController
  def index
    @station = params[:station] || :Central
  end
  
  def compare
    @metric = params[:metric] || :rsp
  end
end