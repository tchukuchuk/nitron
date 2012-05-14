Nitron
===================

Experiments in wrapping the iOS SDK in a more Ruby-esque manner.

Samples
------------

Easily create a UITableViewController that leverages
NSFetchedResultsController to fetch data:

```ruby
class ArtistsViewController < Nitron::TableViewController
  collection { Artist.all }

  layout do |cell, artist|
    cell.textLabel.text = artist.name
  end

  selected do |artist|
    push EventsViewController, :artist => artist
  end
end
```

Each TableViewController is bound to a collection of objects -- either
an `Array`, or a collection accessible by an `NSFetchRequest`. Be sure
to wrap the declaration in a block to ensure it is evaluated as late as
possible.

Like Rails, Nitron strives for convention over configuration. By
default, we initialize properties like the controller's title from the
class name -- in this case, Artists. You may override this by specifying
title, and providing either a static `String`, or a block that returns a
`String`.

Nitron::TableViewController also adds a `push` convenience method to
encapsulate the common pattern of calling the next controller when using a
`UINavigationController`.

Declarative entity specification:

```ruby
class Artist < Nitron::Entity
  field :name,      :type => String
  field :imageUrl,  :type => String
  field :updatedAt, :type => Time
end
```

NOTE: the CoreData integration is more for testing the UI helpers. We're
doing R&D right now to determine the best way to wrap CoreData, as well
as support migrations. If you have thoughts on this, please contact me
via Twitter (@mattgreenrocks).
