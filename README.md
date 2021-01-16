 
# Setting up dependencies

## Install Ruby

1. On MacOS, you may want to install [Chruby](https://github.com/postmodern/chruby), a Ruby version management tool. With it, you can install multiple Ruby versions with `ruby-install ruby 2.7.2` and use Chruby to set which one to use. Follow the instructions in [this Stack Overflow answer](https://stackoverflow.com/a/54873916/362298) for more details.
2. Make sure you update your path to point to the right Ruby version

## Install and setup t

You need to install the [t Twitter command-line tool](https://github.com/sferik/t).

1. Make sure you are using Ruby 2.7.2 (haven't tested with 3.0.0)
2. Run `gem install t`
3. There are some issues with authorizing a Twitter account with the current API. So before continuing, do one of the following:
+ Try downgrading the Ruby Twitter client version: `gem install twitter -v 6.1.0; gem uninstall twitter -v 6.2.0`
* Or try modifying the constant in the t source code following the instructions in [this issue](https://github.com/sferik/twitter/issues/878#issuecomment-349718252)
4. Run `t authorize` and follow the instructions to create an app on your Twitter account. Make sure it has read and write permissions


