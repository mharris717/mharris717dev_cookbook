name             'mharris717'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures mharris717'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "git"
depends 'apt'
depends 'nginx'
depends 'postgresql'
depends 'npm'
depends 'unicorn'
depends 'mongodb'
