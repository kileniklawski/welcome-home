Welcome Home - Hue Panel
====

A lightweight Meteor.JS Hue lights control panel.

###Requirment - Register App

Before you launch Hue Panel you'll need to register the application with your Hue bridge.

###Quick App Install

If you have NodeJS and Meteor already installed, setup is as simple as running `meteor` from the app directory.

Otherwise:

* Install Node: [http://nodejs.org](http://nodejs.org)
* Install Meteor: `curl https://install.meteor.com | /bin/sh`
* Open the control panel in your browser: `http://your_local_ip:3000`

###Options for Deploying

Now that you've tested the app, you may want to set it up to run all the time. There are a couple of options for this.

First thing's first. The app needs to live on the same LAN as the lights it will be controlling.

Next, you could [do a proper production deployment](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-meteor-js-application-on-ubuntu-14-04-with-nginx).

Or (much easier) since it will only ever be accessed over the local network, just run it in the background, using the dev server: `meteor &`


### Providers/source

Initial implementation by [Kelli Shaver](https://github.com/kellishaver/hue-panel)