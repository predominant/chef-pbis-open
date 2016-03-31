pbis-open Cookbook CHANGELOG
============================
This file is used to list changes made in each version of the pbis-open cookbook.

v2.1.0 (2016-30-03)
-------------------
- Fixed idempotence bug (join domain caommna only runs if not already domain member)
- Added support for specifying ou when joining the domain
- Added rspec tests

v2.0.0 (2016-03-03)
-------------------
- Updated to version 8.3
- Added support for CentOS
- Switched to nodes provisioner
- Added fixture cookbook and test suite to create test Windows domain controller
- Added fixture cookbook so that linux vms can find and join the test domain
- Rubocop and foodcritic fixes
