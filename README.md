Nitron
===================

Introduction
----------
Nitron is an opinionated, loosely-coupled set of RubyMotion components designed to accelerate iOS
development, especially with simpler iOS apps. It provides meaningful
abstractions atop the strong foundation present in the iOS SDK.

Philosophy
-----------
We don't aim to rewrite the iOS dev ecosystem in Ruby. Instead, we strive to
make the existing tools work well for RubyMotion development. Why?
Because, currently, there are some things that XCode is better at than the community
alternatives: simple, graphical layouts, and CoreData-based data modeling. This also has a nice secondary benefit, namely that of less 'aftermarket' code, and thus smaller binary size.

Please understand that we're not committed to XCode as much as we are committed to productivity over politics. Currently, the best way to Get Things Done is to drop into XCode occasionally. We're very interested in workflows that remove XCode entirely, but we're not there yet.

This first release focuses on making Storyboard-based workflows enjoyable.

Features
----------

* **Data Binding** - declaratively bind your model data to controls, either
  via code or IB
* **Outlet Support** - expose controls to your controllers via Interface Builder
* **Action Support** - Ruby DSL to attach event handlers to outlets
* **CoreData Models** - beginnings of a CoreData model abstraction uses
  XCode's data modeling tools with an ActiveRecord-like syntax

If you notice, many of these features aim at slimming down your
controllers. This is no accident: many iOS controllers have far too many
responsibilities. Glue code is a perfect target for metaprogramming, so
we're focusing on making beautiful controllers presently.

We're also careful to make these features modular, so you can mix them
into your controllers as needed.

Tutorial
----------
TBD

Examples
----------
https://github.com/mattgreen/nitron-examples

Caveats
---------

* Data binding doesn't use KVO presently. This is already in the works.
* Action support is limited to selecting a button or a table cell.
  Future releases will expand the DSL to support additional events.
* CoreData needs support for relationships and migrations.

