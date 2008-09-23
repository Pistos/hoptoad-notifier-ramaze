### Installation

gem install hoptoad-notifier-ramaze --source http://purepistos.net

### Usage

In your Ramaze application code, put these two lines somewhere before Ramaze.start:

    require 'hoptoad-notifier'
    Ramaze::Helper::HoptoadNotifier.trait[ :api_key ] = 'your-projects-api-key'

### Source

[on github.com](http://github.com/Pistos/hoptoad-notifier-ramaze)

### Support

Pistos in [irc.freenode.net#ramaze](http://mibbit.com/?server=irc.freenode.net&channel=%23ramaze)

