# CPCDS Reference Implementation Client

Reference implementation client for the [Consumer-Directed Payer Data Exchange IG](https://build.fhir.org/ig/HL7/carin-bb/index.html).

## Installation

To pull in remote `cpcds-client-ri` from github for local development:

```
cd ~/path/to/your/workspace/
git clone https://github.com/carin-alliance/cpcds-client-ri.git
```

## Running

Since this app is configured for heroku deployment, running it is slightly 
more effort than just `rails s`.

1. To start, you must be running `postgres`

    ```
    pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
    ```
    (This gets old. Personally, I made a `pg_start` alias for this command)
    Don't forget to setup the database by running:
    ```
    rake db:setup
    ```

2. Next, run the rails app the way you would any other

    ```
    cd ~/path/to/your/app/
    rails s
    ```

3. Now you should be able to see it up and running at `localhost:3000`

4. When done, gracefully stop your `puma` server

    ```
    Control-C
    ```

5. Finally, stop your `postgres` instance

    ```
    pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop
    ```
    (This also gets old. Personally, I made a `pg_stop` alias for this command)

## Copyright

Copyright 2020 The MITRE Corporation
