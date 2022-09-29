# CPCDS Reference Implementation Client

## Description

This is an open source reference implementation client for the [Consumer-Directed Payer Data Exchange IG](https://build.fhir.org/ig/HL7/carin-bb/index.html).

## Features

- Allow users to authenticate to FHIR server supporting the CARIN IG for Blue Button via [SMART App Launch](https://www.hl7.org/fhir/smart-app-launch/)
- Allow authenticated users to retrieve and view their explanation of Benefits statements.

## Hosted Application

The application is hosted on [Heroku](https://www.heroku.com/) and is browseable at <https://cpcds-client-ri.herokuapp.com/home>.

## Running App Locally

### Prerequisites

Make sure you have the following dependencies installed

- **[Ruby](https://www.ruby-lang.org/en/)**
- **[Rails](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails)**
- **[PostgreSQL](https://www.postgresql.org/download/)**
- **[Memcached](https://github.com/memcached/memcached/wiki/Install#installation)**

### Installation

To pull in remote `cpcds-client-ri` from github for local development:

```git
cd ~/path/to/your/workspace/
git clone https://github.com/carin-alliance/cpcds-client-ri.git
```

### Running the App

This app uses PostgreSQL for database and memcached for caching systems.

1. Ensure you have all the prerequisites installed.
2. Ensure that postgre and memcached are running.
3. Change directory to the app directory:

    ```bash
    cd ~/path/to/your/app/
    ```

4. Install the app dependencies:

    ```bash
    bundle install
    ```

5. Setup the database:

    ```bash
    rails db:setup
   ```

6. Run the rails app:

    ```bash
    rails s
    ```

Now you should be able to see the app up and running at `localhost:3000`

### Stopping the App

1. Stop the app by doing `control + c`
2. Stop the postgre server
3. stop the memcached server

## Contributing

Contributions and suggestions are welcome. You can report a bug or suggest a feature via the [GitHub issues tracking](https://github.com/carin-alliance/cpcds-client-ri/issues). You can also submit a [pull request](https://github.com/carin-alliance/cpcds-client-ri/pulls) for a fix or new feature.

## Copyright

Copyright 2022 The MITRE Corporation
