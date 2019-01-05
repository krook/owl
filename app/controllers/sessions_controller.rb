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

class SessionsController < ApplicationController
    def new
    	if signed_in?
    		sign_out
    		redirect_to '/'
	    else
	    	
	    end

	    render layout: "landing"
    end
 
	def create
		user = User.find_by(username: params[:session][:username].downcase)
	    if user && user.authenticate(params[:session][:password])
			sign_in user
			flash[:notice] = "Welcome back " + user.username + "!"
			redirect_to "/home"
	    else
	      flash[:error] = 'Invalid email/password combination'
	      redirect_to "/signin"
	    end
	end

	def destroy
		sign_out
		flash[:success] = "See you again soon!"
		redirect_to "/"
	end
end
