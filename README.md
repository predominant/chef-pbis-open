# pbis-open-cookbook

This cookbook installs and configures PowerBroker Identity Services Open Edition on a Ubuntu server.

## Supported Platforms

Tested on Ubuntu 12.04. Requires a chef-vault item with "username" and "password" keys to be created if the server will join the AD domain automatically. The credentials in the chef-vault item must have permission to join a computer in the domain, or a computer account must be pre-staged appropriately.

## Usage

### pbis-open::default

Installs and configures PBIS Open. Joins the system to the AD domain if configured to do so (see requirements above). Single-line registry entries can be created under `node['pbis-open']['options']` and will be loaded on the next chef-client run. Multi-line entries other than "RequireMembershipOf" are not currently handled by this cookbook.

Note: PBIS Open installation requires a restart, which this cookbook does not handle.

```json
{
  "default_attributes": {
    "pbis-open": {
      "ad_domain": "corp.contoso.com",
      "options": {
        "AssumeDefaultDomain": "true",
        "RequireMembershipOf": [
          "CONTOSO\\\\Domain^Users"
        ]
      }
    }
  },
  "run_list": [
    "recipe[pbis-open]"
  ]
}
```

## License and Authors

Author:: Biola University (<jared.king@biola.edu>)

```text
Copyright 2014, Biola University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```