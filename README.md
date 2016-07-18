# Archimate

I also have included some Ruby code that plays with the `.archimate` file format to produce useful output.

The example scripts are (some are planned):

command        | description
------------- | -----------
`archimate help [COMMAND]` | Describe available commands or one specific command
`archimate dedupe ARCHIFILE` | de-duplicate elements in Archi file
`archimate dupes ARCHIFILE`  | List all duplicate elements in Archi file
`archimate map ARCHIFILE` | Produce a map of diagram links to a diagram
`archimate merge ARCHIFILE1 ARCHIFILE2` | Merge two archimate files
`archimate project ARCHIFILE PROJECTFILE` | Synchronize an Archi file and an MSProject XML file
`archimate quads ARCHIFILE` | Produce a file of Quads to populate a graph database from this model
`archimate svg ARCHIFILE` | Produce semantically meaningful SVG files from an Archi file

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'archimate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install archimate

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/archimate.

## Merge Rules

* One of two docs is considered the parent - ids will default there
* First checks for unique ids are made. Re-mapping will be done if necessary. More on remapping rules below.

## Other tool ideas

* Tool to convert from archi to archimate open-exchange and vice versa.
* Tool to query for dependencies
* Tool to assign/validate/enforce metadata

