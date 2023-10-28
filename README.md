# CPCDS Reference Implementation Client

## Description

This is an open source reference implementation client for the [Consumer-Directed Payer Data Exchange IG](https://build.fhir.org/ig/HL7/carin-bb/index.html).

## Features

- Allow users to authenticate to FHIR server supporting the CARIN IG for Blue Button via [SMART App Launch](https://www.hl7.org/fhir/smart-app-launch/)
- Allow authenticated users to retrieve and view their explanation of Benefits statements.

## Hosted Application

The application is hosted on [Heroku](https://www.heroku.com/) and is browseable at <https://cpcds-client-ri.herokuapp.com/home>.

This app works with the [CPCDS reference server](https://github.com/carin-alliance/cpcds-server-ri). Use the following credentials to connect the hosted client with the CPCDS server:

```bash
Server Base URL: http://cpcds-ri.c3ib.org/cpcds-server/fhir
Client ID: 6cfecf41-e364-44ab-a06f-77f8b0c56c2b
Client Secret: XHNdbHQlOrWXQ8eeXHvZal1EDjI3n2ISlqhtP30Zc89Ad2NuzreoorWQ5P8dPrxtk267SJ23mbxlMzjriAGgkaTnm6Y9f1cOas4Z6xhWXxG43bkIKHhawMR6gGDXAuEWc8wXUHteZIi4YCX6E1qAvGdsXS1KBhkUf1CLcGmauhbCMd73CjMugT527mpLnIebuTp4LYDiJag0usCE6B6fYuTWV21AbvydLnLsMsk83T7aobE4p9R0upL2Ph3OFTE1
```

**Test Patients Login** (username / password)

```txt
Patient1 / password
Patient2 / password
```

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


## Questions and Contributions
Questions about the project can be asked in the [CARIN BlueButton stream on the FHIR Zulip Chat](https://chat.fhir.org/#narrow/stream/204607-CARIN-IG-for-Blue-Button.C2.AE).

This project welcomes Pull Requests. Any issues identified with the RI should be submitted via the [GitHub issue tracker](https://github.com/carin-alliance/cpcds-client-ri/issues).

As of October 1, 2022, The Lantana Consulting Group is responsible for the management and maintenance of this Reference Implementation.
In addition to posting on FHIR Zulip Chat channel mentioned above you can contact [Corey Spears](mailto:corey.spears@lantanagroup.com) for questions or requests.
