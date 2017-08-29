#!/bin/bash

cat > /etc/exports <<EOF
/home/vagrant 192.168.42.0/24(sync,no_root_squash)
EOF

# When nfs::server is applied it will change the mode which will trigger
# 'exportfs -ra'
chmod 0600 /etc/exports
