copy_file "app/controllers/home_controller.rb"
template "app/views/home/index.html.erb.tt"
route 'root "home#index"'
