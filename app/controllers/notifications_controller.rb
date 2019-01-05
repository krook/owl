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

class NotificationsController < ApplicationController

  def index
  	@notifications = Notification.all
  	@newnotification = Notification.new
  end

  def show
  end

  def new
    @notification = Notification.new
  end

  def edit
  end

  def create
    @notification = Notification.new(notification_params)

    respond_to do |format|
      if @notification.save
        format.html { redirect_to "/", notice: 'Notification created.' }
        format.json { render action: 'show', status: :created, location: @notification }
      else
        format.html { render action: 'new' }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { redirect_to @notification }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @notification = notification.find(params[:id])
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to "/", notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def notification_params
      params.require(:notification).permit(:title, :content)
    end
end
