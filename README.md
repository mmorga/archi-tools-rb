# Archimate

I also have included some Ruby code that plays with the `.archimate` file format produces by [Archi](http://archimatetool.com/) to produce useful output.

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

### archimate

The example scripts are (some are planned):

command        | description
------------- | -----------
`archimate help [COMMAND]` | Describe available commands or one specific command
`archimate convert ARCHIFILE` | Convert the incoming file to the desired type
`archimate dedupe ARCHIFILE` | de-duplicate elements in Archi file
`archimate dupes ARCHIFILE`  | List all duplicate elements in Archi file
`archimate map ARCHIFILE` | *EXPERIMENTAL:* Produce a map of diagram links to a diagram
`archimate merge ARCHIFILE1 ARCHIFILE2` | *EXPERIMENTAL:*Merge two archimate files
`archimate project ARCHIFILE PROJECTFILE` | *EXPERIMENTAL:*Synchronize an Archi file and an MSProject XML file
`archimate svg ARCHIFILE` | *IN DEVELOPMENT:* Produce semantically meaningful SVG files from an Archi file

### archidiff & archimerge

Archidiff is a set of tools to help with versioning an `.archimate` file from Archi in a version control system (like git). Eventually I want to provide diff and (3-way) merge tools that understand how *Archi* files are structured and avoid problems that happen when multiple people collaborate on a model.

### fmtxml

Can be used as a `textconv` filter in .gitconfig to pre-format files for better diff use (for visual scanning). You'd set this up in your `$HOME/.gitconfig` file like this.

```
[diff "archimate"]
    textconv = fmtxml
    cachetextconv = true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mmorga/archi-tools-rb.
