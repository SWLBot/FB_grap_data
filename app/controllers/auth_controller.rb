class AuthController < ApplicationController
  def index
    @oauth = Koala::Facebook::OAuth.new('1736802146607522','b17e461faf7cd2b00d7f517ef93a2320','http://localhost:3000/auth/get_token')
    @URL = @oauth.url_for_oauth_code(:permission => "user_managed_groups")
  end
  def get_token

    @oauth = Koala::Facebook::OAuth.new('1736802146607522','b17e461faf7cd2b00d7f517ef93a2320','http://localhost:3000/auth/get_token')
    @token = @oauth.get_access_token(params[:code])
    session[:token] = @token

    redirect_to :action => 'show_groups'
  end
  def show_groups
    if( session.has_key?(:token) )
      @gapi = Koala::Facebook::API.new(session[:token])
      @groups = @gapi.get_connection('me','groups',api_version: "2.6")
    end

  end
  def get_groups
    @gapi = Koala::Facebook::API.new(session[:token])
    @groups = Array(params[:groups])
    @messages = Array.new
    @names = Array.new
    @groups.each do |group|
      page = @gapi.get_connection(group,"feed",{fields: ['message','from','name'] })
      content = Array.new
      while !page.empty?
        content.concat page
        page = page.next_page
      end
      @messages.push(content)
      @names.push(@gapi.get_object(group)['name'])
    end
  end

end
