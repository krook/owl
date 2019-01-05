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

class User < ActiveRecord::Base
	has_secure_password

	before_save { self.username = username.downcase }
	before_create :create_remember_token
	validates :username, uniqueness: true

	def User.new_remember_token
	SecureRandom.urlsafe_base64
	end

	def User.digest(token)
	Digest::SHA1.hexdigest(token.to_s)
	end

	private

		def create_remember_token
		  self.remember_token = User.digest(User.new_remember_token)
		end
end