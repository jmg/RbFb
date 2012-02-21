require "net/https"
require 'cgi'
require 'uri'
require 'json'

module Facebook

    class RbFb

        def initialize app_id, access_token=nil

            @app_id = app_id
            @access_token = access_token

            @GRAPH_URL = "https://graph.facebook.com/"
            @BASE_AUTH_URL = "%soauth/authorize" % @GRAPH_URL
            @BASE_TOKEN_URL = "%soauth/access_token" % @GRAPH_URL
        end

        def _make_request url, data={}

            uri = URI.parse("#{url}?#{_get_url_path data}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Net::HTTP::Get.new(uri.request_uri)

            response = http.request(request)
            response.body
        end

        def _make_auth_request path, data

            url = "#{@GRAPH_URL}#{path}"
            data["access_token"] = @access_token
            _make_request url, data
        end

        def _get_url_path dic

            return URI.encode_www_form(dic)
        end

        def _get_auth_url params, redirect_uri

            params['redirect_uri'] = redirect_uri

            url_path = _get_url_path params
            url = "#{@BASE_AUTH_URL}?#{url_path}"
        end

        def get_auth_code_url redirect_uri, permissions

            params = {
                "client_id" => @app_id,
                "scope" => permissions,
            }
            _get_auth_url params, redirect_uri
        end

        def get_access_token app_secret_key, secret_code, redirect_uri

            @secret_key = app_secret_key

             params = {
                "client_id" => @app_id,
                "client_secret" => app_secret_key,
                "redirect_uri" => redirect_uri,
                "code" => secret_code,
            }

            data = CGI.parse(_make_request @BASE_TOKEN_URL, params)
            @access_token = data['access_token']
            @expires = data['expires']
            @access_token
        end

        def api_call method, params={}
            JSON.parse _make_auth_request method, params
        end
    end

    class RbfbException

        def initialize value
            @value = value
        end
    end

end
