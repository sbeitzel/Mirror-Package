# Mirror-Package

A command-line tool to create or update a local mirror of the dependencies for a
Swift project. This tool is meant to automate a bunch of the typing that is
involved in using SPM [dependency mirroring].

## Basic Usage

Let's say that you want to keep a local mirror of your project's dependencies
in a directory, `/opt/swift/mirrors`. Open a terminal window and change to
your swift project's directory. Then resolve your project's package dependencies:

`swift package resolve`

Now you can use the tool to mirror all the dependencies:

`Mirror-Package -m /opt/swift/mirrors`

Later, if you want to update your local mirrors, you can use the tool to do
that, too:

`Mirror-Package -m /opt/swift/mirrors -u`

Note that the update process can happen from any directory, since it just
goes through all the subdirectories of the specified mirror directory and
does a `git pull --rebase` for each one.

To stop using the mirrors, simply delete `.swiftpm/config` from your project.

[dependency mirroring]: https://github.com/apple/swift-evolution/blob/main/proposals/0219-package-manager-dependency-mirroring.md
