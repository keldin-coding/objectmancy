# Changelog

## Version 2.0.0
The fact that this is version 2 is insane, but I technically introduced a breaking change by requiring Ruby version 2.1 or higher with the Hashable functionality.

### Non-passive changes
* `Objectmancy` requires Ruby version 2.1 or higher

### Improvements
* Adds comparator for all classes including Objectable.
* Extracted commonalities to common area.
* Adds ability to update attributes.
* Adds hashability for basic attributes and other Hashable objects.
* Adds hashability support for custom attributes.
* Adds Hashability  support for multiples of Hashable objects or special Hashable objects.

## Version 1.0.0

### Improvements
* Allows creation of objects with raw data (i.e. no fancy conversion).
* Adds support for datetimes.
* Adds support for objectable on any arbitrary object.
* Adds support for multiples. That is, arrays of special objects.
* Adds support for initialize callbacks.
