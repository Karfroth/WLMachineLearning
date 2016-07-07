# WLMachineLearning

This is a repositoy for the ruby gem about machine learning. I am developing this for my personal perpose now.

## Installation

Under Development now

<del>Add this line to your application's Gemfile:</del>

<del>```ruby
gem 'WLMachineLearning'
```</del>

<del>And then execute:</del>

<del>    $ bundle</del>

<del>Or install it yourself as:</del>

<del>    $ gem install WLMachineLearning</del>

## ToDo

This library is still under develpment. I tried to code with other Ruby libraries as much as possible, but the result is very disappointing. So I decided to develop with other language. And unfortunately, Scala is most fastest language I know. So, yes, this will be a gem for JRuby.

You can check my Scala code [here](https://github.com/karfroth/WLML_Scala).

* Regression                        [　]
* Regularization with L1/L2 Penalty [　]
* Logistic Regression               [　]
* Tree                              [　]
* Boosted Tree (Ada Boost)          [　]
* K-Means Clustering                [　]

## Requirement

This gem use [breeze](https://github.com/scalanlp/breeze) and [netlib-java](https://github.com/fommil/netlib-java).


### Linux
* libblas.so.3
* libgfortran.so.3
* liblapack.so.3

If you are Fedora user, try this command.

    $ sudo dnf install -y blas lapack libgfortran

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/karfroth/WLMachineLearning.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
