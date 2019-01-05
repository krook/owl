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

class ClusterdatasController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @clusterdatas = Clusterdatum.all
  end

  def show
    @clusterdata = Clusterdatum.find(params[:id])
  end

  def new
    @clusterdata = Clusterdatum.new
  end

  def edit
  end

  def create
    @clusterdata = Clusterdatum.new(clusterdata_params)

    respond_to do |format|
      if @clusterdata.save
        format.html { redirect_to "/clusterdatas", notice: 'clusterdata created.' }
        format.json { render action: 'show', status: :created, location: @clusterdata }
      else
        format.html { render action: 'new' }
        format.json { render json: @clusterdata.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @clusterdata = Clusterdatum.find(params[:id])
    respond_to do |format|
      if @clusterdata.update(clusterdata_params)
        format.html { redirect_to @clusterdata, notice: 'clusterdata was successfully updated.' }
        format.json { render :show, status: :ok, location: @clusterdata }
      else
        format.html { redirect_to @clusterdata }
        format.json { render json: @clusterdata.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @clusterdata = Clusterdatum.find(params[:id])
    @clusterdata.destroy
    respond_to do |format|
      format.html { redirect_to "/clusterdatas", notice: 'clusterdata was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def clusterdata_params
      params.require(:clusterdata).permit(:content)
    end
end