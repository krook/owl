# Copyright 2018 Bryan Knouse, Magus Pereira, Charlie Evans, Taraqur Rahman, Nick Feuer
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class IncidentsController < ApplicationController

  def index
    @user = current_user
    @incident = Incident.new
    @incidents = Incident.all
  end

  def show
    @incident = Incident.find(params[:id])
  end

  def new
    @incident = Incident.new
  end

  def edit
  end

  def create
    @incident = Incident.new(incident_params)

    respond_to do |format|
      if @incident.save
        format.html { redirect_to "/incidents", notice: 'Incident created.' }
        format.json { render action: 'show', status: :created, location: @incident }
      else
        format.html { render action: 'new' }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @incident = Incident.find(params[:id])
    respond_to do |format|
      if @incident.update(incident_params)
        format.html { redirect_to @incident, notice: 'Incident was successfully updated.' }
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { redirect_to @incident }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @incident = Incident.find(params[:id])
    @incident.destroy
    # respond_to do |format|
    #   format.html { render "/incidents", notice: 'incident was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private

    def incident_params
      params.require(:incident).permit(:name, :location, :managers, :impacted, :casualties)
    end
end