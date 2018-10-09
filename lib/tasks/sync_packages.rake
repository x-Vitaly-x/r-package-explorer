namespace :packages do
  task :sync => :environment do
    Package.sync_packages!(50)
  end
end
