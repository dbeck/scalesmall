ScaleSmall
==========

ScaleSmall project is an experiment for creating a high performance, distributed system for handling large quantities of small data. The first component written in this experiment is responsible for managing group membership. This GroupManager is available under [apps/group_manager](apps/group_manager)

To use the `GroupManager` it is highly recomended to add config items like this:

```elixir
use Mix.Config

config :group_manager,
  my_addr: System.get_env("GROUP_MANAGER_ADDRESS"),
  my_port: System.get_env("GROUP_MANAGER_PORT") || "29999",
  multicast_addr: System.get_env("GROUP_MANAGER_MULTICAST_ADDRESS") || "224.1.1.1",
  multicast_port: System.get_env("GROUP_MANAGER_MULTICAST_PORT") || "29999",
  multicast_ttl: System.get_env("GROUP_MANAGER_MULTICAST_TTL") || "4",
  key: System.get_env("GROUP_MANAGER_KEY") || "01234567890123456789012345678912"
```

Add this to your dependencies:

```elixir
{:scalesmall, git: "https://github.com/dbeck/scalesmall.git", tag: "0.0.5"}
```

And start the `group_manager` application.

The group manager usage is documented [here](apps/group_manager) and [here](apps/group_manager/lib/group_manager.ex).

License
=======

Copyright (c) 2015 [David Beck](http://dbeck.github.io)

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
