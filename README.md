Makers BnB.
------

### Our task

To create a mock version of AirBnB that allows the user to create, search and book venues. We made an extra step by making possible adding a venue as a favourite.

### Our approach

We wanted to use this experience to learn everything we could, having that in mind we tried to integrate both Sinatra a Jquery on the same project.

#### We also:
- Had a Stand Up every day to choose and separate task.
- Had a midday reunion to check the team progress.
- Had a constant communication flow and asked each other for help.
- Had a Retro every night to make an assessment of the day's activities and set new tasks for the next day.

#### We learned:
- How to set up databases.
- How to use Jquery and Sinatra to make post and get requests.
- That making a whole project in one week is possible if you work hard.
- Communication changes everything.
- Coding with a good team is fun.

### How to start
- Ruby version should be "2.4.1", run ```rvm install 2.4.1``` to get it, then ```rvm 2.4.1``` to use that ruby version.
- Check that "postgresql" is installed. if not, follow the [official instructions](https://www.postgresql.org/download/) on how to install it.
- Then install the bundler ```gem install bundler```, and install the gems on the "Gemfile" by running ```bundle install```.
- in the command line type ```psql psotgres```, then ```create database makersbnb_test;``` you should see ```CREATE DATABASE``` as an output, now ```create database makersbnb_development;``` now close postgresql ```\q```

#### To run tests
- If you followed the previous steps ```bundle exec rspec``` should do the work

#### To run the program
- in the command line type ```rackup config.ru -p 2000```
- go to your browser and type "http://localhost:2000/"

### Tech stack
- Ruby:
  -- Sinatra.
- Javascript:
  -- Jquery.
- DB:
  -- Postgresql.
  -- Datamapper.

### Contributors
- [Andrew Davey](https://github.com/ajdavey8)
- [Cristhian Da Silva](https://github.com/cristhiandas)
- [Joe Cowton](https://github.com/joecowton)
- [Cristhian Da Silva](https://github.com/cristhiandas)
