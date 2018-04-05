bin/setup system:install --email='admin@example.net' --password='admin123' --db-host='db' --db-user='phraseanet' --db-password='db_password_123' --db-template=en --databox='phraseanet_data' --appbox='phraseanet_app' --server-name='localhost' --yes



files that need to be mounted:

    ./config/configuration.yml

The recompile the configration

    bin/console compile:configuration
    
To create the elasticsearch index

    bin/console searchengine:index:create
