# Archimate

I also have included some Ruby code that plays with the `.archimate` file format to produce useful output.

The example scripts are (some are planned):

script        | description
------------- | -----------
`diagrammap`  | Outputs a text table mapping the id based file name of the HTML output from Archi to the diagram names and ArchiMate Viewpoints.
`projectplan` | Reads in and merges an XML format MS Project Plan with an Archi project file using Work Units and Deliverables to map to the Project.
`showme`      | Is an experiment to reproduce SVG versions of the diagrams in the ArchiMate file that are semantically meaningful and annotated such that better web user interfaces can be built around the SVG images.
`zachman`     | Make a Zachman HTML page for the project using annotations on ArchiMate diagrams to indicate where in the Zachman matrix the diagram belongs.
`merge`       | Merges two `.archimate` files looking for common names to associate common concepts.

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

