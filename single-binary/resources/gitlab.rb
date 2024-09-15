gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_sync_profile_from_provider'] = ['azure_oauth2']
gitlab_rails['omniauth_sync_profile_attributes'] = ['name', 'email', 'location']
gitlab_rails['omniauth_allow_single_sign_on'] = ['azure_oauth2']
gitlab_rails['omniauth_block_auto_created_users'] = true
gitlab_rails['omniauth_auto_link_ldap_user'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = false
gitlab_rails['omniauth_auto_link_user'] =  ['azure_oauth2']
gitlab_rails['omniauth_external_providers'] = []
gitlab_rails['omniauth_providers'] = [
  {
    name: "azure_oauth2",
    label: "Azure OIDC", # optional label for login button, defaults to "Openid Connect"
    args: {
      name: "azure_oauth2", # this matches the existing azure_oauth2 provider name, and only the strategy_class immediately below configures OpenID Connect
      strategy_class: "OmniAuth::Strategies::OpenIDConnect",
      scope: ["openid", "profile", "email"],
      response_type: "code",
      issuer:  "https://login.microsoftonline.com/todo/v2.0",
      client_auth_method: "query",
      discovery: true,
      uid_field: "sub",
      send_scope_to_token_endpoint: "false",
      client_options: {
        identifier: "todo",
        secret: "todo",
        redirect_uri: "https://my-gitlab/users/auth/azure_oauth2/callback"
      }
    }
  }
]
