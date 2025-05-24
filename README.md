# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version - 3.2.2
# Local Setup

## System dependencies

- Ruby 3.2.2
- Rails 7.2
- Postgresgql@14(local,test) or cockroachdb (for production)


* Configuration \
- Install ruby via rvm with command ```rvm install ruby-3.2.2```


* Database creation \
- Command: ``` rails db:create ```

* Database initialization \
- Command: ``` rails db:migrate; rails db:seed; ```

* How to run the test suite \
- Command: ``` bundle exec rspec ```

* Services (job queues, cache servers, search engines, etc.) \
- Right now there is no other services but in future will be adding sidekiq and Elastic search servers for Background jobs and searching capabilities.

* Deployment instructions \
- The Application is already deployed to https://homey-assignment.onrender.com/login
  ``` admin_username: user admin_password: password ```
        

* ...
