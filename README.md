# TestCaseGenerator

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/test_case_generator`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'test_case_generator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install test_case_generator

## Usage

Write a .testcase file.

Ex. Tests for a TableView in ViewController (YMTableView.testcase)

    before { |items|
      items << :prepareTarget
    }

    concat {
      choice { |items|
        items << :emptyList
        items << :oneItemInList
        items << :manyItemsInList
      }

      choice { |items|
        items << [:viewDidLoad, :viewDidUnload]
        items << [:viewDidLoad, :viewWillAppear, :viewDidAppear, :viewWillDisappear, :viewDidDisappear, :viewDidUnload]
      }
    }

    after { |items|
      items << :releaseTarget
    }

To generate the .m file, run the test_case_generator. (YMTableView.m)

    bundle exec test_case_generator inject YMTableView.testcase YMTableView.m

If the .testcase file is modified after generated, rerun the test_case_generator.

    bundle exec test_case_generator inject YMTableView.testcase YMTableView.m

Do not delete %% marker in the generated .m file because the lines after %% marker is rewritten.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec test_case_generator` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ym-kaoru/test_case_generator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

