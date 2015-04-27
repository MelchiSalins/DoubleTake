# DoubleTake

DoubleTake is a Visual regression testing tool for web-applications. It is packaged and distributed as a Ruby Gem.


## Installation


Install it using:

    $ gem install doubletake

## Usage

To list all available features and functionality:
    $ doubletake help

To see details on usage of each feature:
    $ doubletake help [COMMAND]

## Quick Start Guide

### Compare

#### Why?

CSS allows changes to be made easily but very difficult to make sure those changes don't produce unexpected
consequences elsewhere in the project.

#### How?

DoubleTake is a command line tool and is configured using a YAML file.

Generating and editing a config file is easy.
```
Run:
   $ doubletake generate --file /tmp/mysite_config.yml
```

Use your preferred file editor and edit the config file.
    ```
    $ vim /tmp/mysite_config.yml
    stage: 'https://mysite-stage-env.com'
    prod:  'https://mysite-prod-env.com'
    ```
*NOTE*: Always add the scheme of the site while configuring i.e, http:// or https://

Edit the ignored list to skip URIs or file formats. DoubleTake generates sensible defaults that can be extended.

Testing multiple window resolutions for responsive design is made possible in DoubleTake.
By default DoubleTake generated config file has 3 resolutions:

```
SCREEN_RESOLUTION:
  :desktop:
  - 1400
  - 800
  :tablet:
  - 640
  - 480
  :mobile:
  - 300
  - 600
```
The above configuration has Desktop mode set to 1400x800, tablet to 640x480 and mobile to 300x600. This can be edited and extended
to something like this:

```
SCREEN_RESOLUTION:
  :desktop:
  - 1024
  - 800
  :tablet:
  - 640
  - 480
  :mobile:
  - 300
  - 550
  :iphone6:
  - 375
  - 667
```

DoubleTake is cable to authenticate with user credentials provided in the config file. This allows more in-depth scans.

To do this simple make the following changes to the YAML file.
```
LOGIN: true
LOGIN_URI: user/login
USER_DOM_ID: edit-name
USER_VALUE: username
PASS_DOM_ID: edit-pass
PASS_VALUE: secret_password
```
LOGIN_URI is the path where a user has to navigate to reach the login page. For example:
https://mysite.com/login is the complete URL then the LOGIN_URI would be.
```
LOGIN_URI: login
```
USER_DOM_ID & PASS_DOM_ID are the web element ID which Selenium uses to find and type in the credentials.
USER_VALUE & PASS_VALUE are the actual username and password to login.

If you want DoubleTake to assert if it was successfully able to login with the given details:
```
LOGIN_CONFIRM: true
LOGIN_CONFIRM_CHECK: homepage-onsite-team
```

LOGIN_CONFIRM_CHECK: is the ID of the web element it should find if it was successfully able to login.

If you don't want to use this feature you can turn it off by setting
 ```
 LOGIN_CONFIRM: false
 ```
There are other values in the config file such as
```
bad_links: []
to_be_scraped: []
scraped: []
LOGGED_IN: false
```
These are auto populated by DoubleTake during runtime and used with the Resume feature. Resume is covered later in this guide.

Now that we have our config file ready we can launch our first scan.

    $ doubletake compare --conf /tmp/mysite_config.yml

If the Gem installed correctly and selenium was able to find the Firefox binary you will see two browsers loading pages and
DoubleTake will be taking screenshots and does image comparision.

Pages that have changed will have their screenshots saved in DoubleTake_data folder in your home directory.

### Scrape

#### Why?

Short answer is: I have been asked several times in the past to make complete site backups and preserve how they render in
multiple browsers. This was generally when a major revamp of the site was going to be made or as evidence to show to the client.
There are also times when the UI/UX developers need to quickly see how all the pages look without having to browse every single
page and prefer to see screenshots.

#### How?

All features in DoubleTake make use of the same config file format. We can reuse the config file we made earlier.

Scrape only looks at the "stage: " value in the config and ignores  "prod: ".

To scrape the URL:
    $ doubletake scrape --conf /tmp/mysite_config.yml

This time you should see only one Firefox browser launch and all the screenshots will be stored in DoubleTake_data folder in
your home directory.

### Resume

#### Why?

Cause shit happens and you don't want to restart a scan of a 4000 page e-commerce site after it has already scanned 2500 page.

#### How?

A progress config file is auto-generated when a Compare or Scrape scan is started. These files can be found in DoubleTake_data
folder in the home directory

Ex: ~/DoubleTake_data/desktop/progress_mysite.yml

In addition to this progress config file we also need to known the type of the scan that is being resumed i.e, compare / scrape

To Resume a scan:
    $ doubletake resume --type compare --conf ~/DoubleTake_data/desktop/progress_mysite.com.yml


## Contributing

1. Fork it ( https://github.com/MelchiSalins/doubletake/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
