maintainer       "Relevance"
maintainer_email "opfor@thinkrelevance.com"
license          "All rights reserved"
description      "Installs/Configures Ruby"
recipe           "ruby", "Installs and configures Ruby"
recipe           "ruby::path", "Adds Ruby to every user's PATH"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
