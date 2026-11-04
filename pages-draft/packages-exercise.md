# Package Installations : Exercise

```aside
This page assumes that you have read the [Package Installation Problem](packages.html) page and the page on [handling bigger problems with domains and parameters](domains-and-parameters.html).
```

Here is a simplified alternative to the package installation problem that doesn't pair packages with versions. Instead, the conflicts between packages are listed explicitly.

Fill in the parts marked `fill_this_in` as follows:

1. Complete the definition of `depends` to express that package `p` depends on package `dependency`
2. Complete the definition of `conflict` to express that package `p1` and package `p2` cannot be installed simultaneously.
3. Complete the definition of `depends_or` to express that package `p` depends on package `dependency1` OR `dependency2`.
4. Complete `dependencies_and_conflicts` to express:
   1. `ChatServer` depends on `MailServer` or `MailServer2`
   2. `ChatServer` depends on `Database1` or `Database2`
   3. `MailServer1` and `MailServer2` conflict
   4. `Database1` and `Database2` conflict
   5. `GitServer` depends on `Database2`
5. Complete `requirements` to express that `ChatServer` and `GitServer` must be installed.

```lmt {id=cw1-question2}
domain package {
  ChatServer, MailServer1, MailServer2,
  Database1, Database2, GitServer
}

atom installed(p : package)

define depends(p : package, dependency : package) {
  fill_this_in
}

define conflict(p1 : package, p2 : package) {
  fill_this_in
}

define depends_or(p : package,
                  dependency1 : package,
                  dependency2 : package) {
  fill_this_in
}

define dependencies_and_conflicts {
  fill_this_in
}

define requirements {
  fill_this_in
}

allsat(dependencies_and_conflicts & requirements)
  { for(packageName : package)
      packageName : installed(packageName)
  }
```

There should be two possible satisfying assignments when you click "Run".
