# Voltaserve iOS

Watch the [demo video](https://youtu.be/RpHp0OEa_o8?feature=shared).

## Use with Voltaserve Cloud

- Install the app on your device with Xcode.
- Sign up if you don't have an account yet.
- Sign in and enjoy!

## Use with Your Own Voltaserve Instance

- Make sure your Voltaserve instance is up and running, or follow the instructions [here](https://github.com/kouprlabs/voltaserve) to create a new instance.
- Install the app on your device with Xcode.
- On the sign in screen, in the upper right corner, click the cog button to create a new server that points to the URLs of your instance, **then activate it**, example URLs:
  - API: `http://localhost:8080`
  - Identity Provider: `http://localhost:8081`
- Sign in and enjoy!

## Getting Started

Prerequisites:

- Install [Xcode](https://developer.apple.com/xcode/).
- Install [SwiftLint](https://github.com/realm/SwiftLint).

Format code:

```shell
swift format -i -r .
```

Lint code:

```shell
swift format lint -r .
```

```shell
swiftlint lint --strict .
```

## Licensing

Voltaserve is released under the [Business Source License 1.1](LICENSE).
