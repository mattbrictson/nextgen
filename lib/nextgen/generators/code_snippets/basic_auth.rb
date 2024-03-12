document_deploy_var "BASIC_AUTH_PASSWORD"
document_deploy_var "BASIC_AUTH_USERNAME",
  "If this and `BASIC_AUTH_PASSWORD` are present, visitors must use these credentials to access the app"
copy_file "app/controllers/concerns/basic_auth.rb"
inject_into_class "app/controllers/application_controller.rb", "ApplicationController", "  include BasicAuth\n"
