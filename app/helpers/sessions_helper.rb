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

module SessionsHelper
  def sign_in(user)
      remember_token = User.new_remember_token
      cookies.permanent[:remember_token] = remember_token
      user.update_attribute(:remember_token, User.digest(remember_token))
      self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
      remember_token = User.digest(cookies[:remember_token])
      @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_album=(album)
    @album = album
  end

  def current_album
    
  end

  def signed_in_user
    unless signed_in?
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.digest(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end
end