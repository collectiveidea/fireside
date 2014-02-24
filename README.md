# Fireside

Fireside is an open source chat application with a *familiar* API.

## Installation

Fireside is a Rails application that can be deployed to your own server, but is
designed to be easily and freely deployed to Heroku.

First, you'll need the Heroku Toolbelt:

```
brew install heroku-toolbelt
```

Then deployment is easy:

```
git clone https://github.com/collectiveidea/fireside.git
cd fireside
cp config/application{.example,}.yml
heroku apps:create
git push heroku master
```

You'll want to create some users and rooms:

```
heroku run rails console
 > User.create!(name: "John Doe", email: "john@example.com", password: "secret")
 > User.create!(name: "Jane Doe", email: "jane@example.com", password: "secret")
 > Room.create!(name: "Break Room")
```

That's all you need to start interacting with the API. See the [API Documentation](doc/api.md) for more information.

See [`config/application.yml`](config/application.example.yml) for available configuration options.

## Client Support

🚧 Under Construction

## Development

### Requirements

Fireside development requires:

* Ruby 2.1
* PostgreSQL

### Setup

Fork and clone the project, then:

```
cp config/application{.example,}.yml
cp config/database{.example,}.yml # and update
bundle install
bundle exec rspec
```

### Objectives

New development on Fireside should meet one of the following needs:

* #### Tests

  Any code with poor (or no) test coverage should be covered with tests. 100% coverage isn't necessary but… go for it anyway.

* #### Bugfixes

  Inconsistent or unexpected API behavior should be patched to meet users' expectations as faithfully as possible. Fixes must be covered with tests.

* #### Documentation

  Please contribute to documentation by making it more complete, clearer, better organized and free of typos. Please include `[ci skip]` in your commit messages.

* #### Performance

  Contributions will be accepted that have no effect on the public API if the changes increase performance significantly. Preference will be given to contributions that do not introduce new runtime dependencies.

* #### Refactoring

  Any code is fair game for refactoring. Refactors often boil down to personal preference so it might be wise to ask about your proposed changes before you build them.

* #### Style

  Fireside attempts to follow [GitHub's Ruby Style Guide](https://github.com/styleguide/ruby) and will accept contributions to make the code adhere to it more closely. Contributions falling into *any* of the above categories are expected to follow this style.

### Contribution

When sending a [pull request](https://github.com/collectiveidea/fireside/pulls), [issue](https://github.com/collectiveidea/fireside/issues) or comment, please be:

1. polite
2. helpful
3. verbose (placing large code examples in a [Gist](https://gist.github.com))
4. funny (animated GIFs and Emoji encouraged)
