Application for viewing and parsing through R package list.

* install all the gems in the bundler
* initialize database with usual `rake db:create/migrate`
* run `rake packages:sync` either manually or through cron to fill up the database
* start the app normally with `rails s`
