![Helios - an extensible open source mobile backend framework](https://raw.github.com/helios-framework/helios.io/assets/helios-banner.png)

Helios is an open-source framework that provides essential backend services for iOS apps, from data synchronization and user accounts to push notifications, in-app purchases, and passbook integration. It allows developers to get a client-server app up-and-running in just a few minutes, and seamlessly incorporate functionality as necessary.

Helios is designed for "mobile first" development. Build out great features on the device, and implement the server-side components as necessary. Pour all of your energy into crafting a great user experience, rather than getting mired down with the backend.

One great example of this philosophy in Helios is Core Data Synchronization. This allows you to use your existing Core Data model definition to automatically generate a REST webservice, which can be used to shuttle data between the server and client. No iCloud, _no problem_.

![Helios Web UI Screenshot](https://raw.github.com/helios-framework/helios.io/assets/helios-screenshot.png)

Helios also comes with a Web UI. Browse and search through all of your database records, push notification registrations, in-app purchases, and passbook passes. You can even send targeted push notifications right from the browser.

---

## Requirements

- Ruby 1.9
- PostgreSQL 9.1 _([Postgres.app](http://postgresapp.com) is the easiest way to get a Postgres server running on your Mac)_

## Getting Started

1. Install Helios at the command prompt:

    $ gem install helios

2. Create a new Helios application:

    $ helios new myapp

3. Change directory to `myapp` and start the web server:

    $ cd myapp; helios server

4. Go to http://localhost:5000/admin and you’ll see your app's Web UI

Read on for instructions on the following:

- Linking a Core Data model
- Integrating Helios into your mobile client

## Usage

Built on the Rack webserver interface, Helios can be easily added into any existing Rails or Sinatra application as middleware. Or, if you're starting with a Helios application, you can build a new Rails or Sinatra application on top of it.

This means that you can develop your application using the tools and frameworks you love, and maintain flexibility with your architecture as your needs evolve.

### Sinatra / Rack

#### Gemfile

```ruby
gem 'helios'
```

#### config.ru

```ruby
require 'bundler'
Bundler.require

run Helios::Application.new do
      service :data, model: 'path/to/DataModel.xcdatamodel'
      service :push_notification
      service :in_app_purchase
      service :passbook
    end
```

### Rails

To create a Rails app that uses Postgres as its database, pass the `-d postgresql` argument to the `rails new` command:

    $ rails new APP_PATH -d postgresql

If you're adding Helios to an existing Rails project, be sure to specify a PostgreSQL database in `config/database.yml` and check that the `pg` gem is included in your `Gemfile`:

#### Gemfile

    gem 'helios'
    gem 'pg'

Helios can be run as Rails middleware by adding this to the configuration block in `config/application.rb`

#### config/application.rb

```ruby
config.middleware.use Helios::Application do
  service :data, model: 'path/to/DataModel.xcdatamodel'
  service :push_notification
  service :in_app_purchase
  service :passbook
end
```

## Available Services

Each service in Helios can be enabled and configured separately:

`data`: Generates a REST webservice from a schema definition. Currently supports Core Data (`.xcdatamodel`) files.

**Parameters**

- `model`: Path to the data model file

**Associated Classes**

Each entity in the specified data model will have a `Sequel::Model` subclass created for it under the `Rack::CoreData::Models` namespace.

<table>
  <caption>Endpoints</caption>
  <tr>
    <td><tt>GET /:resources</tt></td>
    <td>Get list of all of the specified resources</td>
  </tr>
  <tr>
    <td><tt>POST /:resources</tt></td>
    <td>Create a new instance of the specified resource</td>
  </tr>
  <tr>
    <td><tt>GET /:resources/:id</tt></td>
    <td>Get the specified resource instance</td>
  </tr>
  <tr>
    <td><tt>PUT /:resources/:id</tt></td>
    <td>Update the specified resource instance</td>
  </tr>
  <tr>
    <td><tt>DELETE /:resources/:id</tt></td>
    <td>Delege the specified resource instance</td>
  </tr>
</table>

---

`push_notification`: Adds iOS push notification registration / unregistration endpoints.

**Associated Classes**

- `Rack::PushNotification::Device`

<table>
  <caption>Endpoints</caption>
  <tr>
    <td><tt>PUT /devices/:token</tt></td>
    <td>Register or update existing device for push notifications</td>
  </tr>
  <tr>
    <td><tt>DELETE /devices/:token</tt></td>
    <td>Unregister a device from receiving push notifications</td>
  </tr>
</table>

---

`in_app_purchase`: Adds an endpoint for iOS in-app purchase receipt verification endpoints, as well one for returning product identifiers.

**Associated Classes**

- `Rack::InAppPurchase::Receipt`
- `Rack::InAppPurchase::Product`

<table>
  <caption>Endpoints</caption>
  <tr>
    <td><tt>POST /receipts/verify</tt></td>
    <td>Decode the associated Base64-encoded <tt>receipt-data</tt>, recording the receipt data and verifying the information with Apple</td>
  </tr>
  <tr>
    <td><tt>GET /products/identifiers</tt></td>
    <td>Return an array of valid product identifiers</td>
  </tr>
</table>

---

`passbook`: Adds endpoints for the [web service protocol](https://developer.apple.com/library/prerelease/ios/#documentation/PassKit/Reference/PassKit_WebService/WebService.html) for communicating with Passbook

**Associated Classes**

- `Rack::Passbook::Pass`
- `Rack::Passbook::Registration`

<table>
  <caption>Endpoints</caption>
  <tr>
    <td><tt>GET /v1/passes/:passTypeIdentifier/:serialNumber</tt></td>
    <td>Get the Latest Version of a Pass</td>
  </tr>
  <tr>
    <td><tt>GET /v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier[?passesUpdatedSince=tag]</tt></td>
    <td>Get the Serial Numbers for Passes Associated with a Device</td>
  </tr>
  <tr>
    <td><tt>POST /v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber</tt></td>
    <td>Register a Device to Receive Push Notifications for a Pass</td>
  </tr>
  <tr>
    <td><tt>DELETE /v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber</tt></td>
    <td>Unregister a Device</td>
  </tr>
</table>

## Command-Line Interface

Helios comes with a CLI to help create and manage your application. After you `$ gem install helios`, you'll have the `helios` binary available.

    $ helios --help
    helios

    A command-line interface for building mobile infrastructures

    Commands:
      console              Open IRB session with Helios environment
      help                 Display global or [command] help documentation.
      link                 Links a Core Data model
      new                  Creates a new Helios project
      server               Start running Helios locally

### Creating an Application

The first step to using Helios is to create a new application. This can be done with the `$ helios new` command, which should be familiar if you've ever used Rails.

    $ helios new --help

    Usage: helios new path/to/app

      The `helios new` command creates a new Helios application with a default
    directory structure and configuration at the path you specify.

    Options:
      --skip-gemfile       Don't create a Gemfile
      -B, --skip-bundle    Don't run bundle install
      -G, --skip-git       Don't create a git repository
      --edge               Setup the application with Gemfile pointing to Helios repository
      -f, --force          Overwrite files that already exist
      -p, --pretend        Run but do not make any changes
      -s, --skip           Skip files that already exist

### Linking a Core Data Model

In order to keep your data model and REST webservices in sync, you can link it to your helios application:

    $ helios link path/to/DataModel.xcdatamodel

This creates a hard link between the data model file in your Xcode and Helios projects—any changes made to either file will affect both. The next time you start the server, Helios will automatically migrate the database to create tables and insert columns to accomodate any new entities or attributes.

### Starting the Application Locally

To run Helios in development mode on `localhost`, run the `server` command:

    $ helios server

### Running the Helios Console

You can start an IRB session with the runtime environment of the Helios application with the `console` command:

    $ helios console

This command activates the services as configured by your Helios application, including any generated Core Data models. The `rack` module is automatically included on launch, allowing you to access everything more directly:

    > Passbook::Passes.all # => [...]

## Deploying to Heroku

[Heroku](http://www.heroku.com) is the easiest way to get your app up and running. For full instructions on how to get started, check out ["Getting Started with Ruby on Heroku"](https://devcenter.heroku.com/articles/ruby).

Once you've installed the [Heroku Toolbelt](https://toolbelt.heroku.com), and have a Heroku account, enter the following commands from the project directory:

    $ heroku create
    $ git push heroku master

## Integrating with iOS Application

### Core Data Synchronization

With [AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore), you can integrate your Helios app directly into the Core Data stack. Whether it’s a fetch or save changes request, or fulfilling an attribute or relation fault, AFIncrementalStore handles all of the networking needed to read and write to and from the server.

See ["Building an iOS App with AFIncrementalStore and the Core Data Buildpack"](https://devcenter.heroku.com/articles/ios-core-data-buildpack-app) on the Heroku Dev Center for a comprehensive guide on how to use AFIncrementalStore with the Core Data buildpack. An article for Helios is forthcoming, but aside from deployment, the instructions are essentially unchanged.

### Push Notification Registration

```objective-c
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSURL *serverURL = [NSURL URLWithString:@"http://raging-notification-3556.herokuapp.com/"];
    Orbiter *orbiter = [[Orbiter alloc] initWithBaseURL:serverURL credential:nil];
    [orbiter registerDeviceToken:deviceToken withAlias:nil success:^(id responseObject) {
        NSLog(@"Registration Success: %@", responseObject);
    } failure:^(NSError *error) {
        NSLog(@"Registration Error: %@", error);
    }];
}
```

---

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- <mattt@heroku.com>

## License

Helios is released under the [MIT](http://opensource.org/licenses/MIT) license.
