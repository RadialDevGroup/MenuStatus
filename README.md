# Slack Menu Status

This application allows you to easily see and update your Slack status in the OSX Menu Bar.

## Technology and Stack

- [Swift](https://swift.org/)
- [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)
- [Sourcery](https://github.com/krzysztofzablocki/Sourcery)
- [Carthage](https://github.com/Carthage/Carthage)

## Setup

1. Clone the repo.
1. Install XCode 9.4 or newer.
1. Install [Sourcery](https://github.com/krzysztofzablocki/Sourcery) and make it available on your path. It is used by the project's Build process to dynamically generate a Swift object with your app's key and secret.
1. Create a `env-vars.sh` file from the `env-vars.sh.example`. This file is also used to dynamically generate a Swift object available in your application with your app's key and secret. If you are creating your own Slack app for development the app currently needs the `user.profile:read` and `user.profile:write` scopes.
1. Run `carthage update` to build the dependencies.

## Debugging

With the project open in XCode, select the Product menu, then Run option

## Archiving

With the project open in XCode, select the Product menu, then Archive. Chose the newly created archive, then click the Export button on the left to follow steps to export an un-signed binary.

## Development Process
- See [PROCESS](PROCESS.md)
- Follow the [STYLEGUIDE](STYLEGUIDE.md)

## Deployment History

- Deployed on 8/2/2018 with xCode 9.4.1 and OSX High Sierra 10.13.6