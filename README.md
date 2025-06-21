<!-- markdownlint-disable MD033 MD041 -->
<p align="center">
  <img height="70" src=".assets/brand-20250421130000.svg" />
  <h1 align="center">Voltaserve for iOS and iPadOS</h1>
</p>

<h3 align="center">Cloud Storage for Creators</h2>

<p align="center">
  <a href="https://apps.apple.com/app/id6744360805">
    <img height="40" src=".assets/app-store-20250424234000.svg" />
  </a>
  <a href="https://apps.apple.com/mac/app/id6744360805">
    <img height="40" src=".assets/mac-app-store-20250424234000.svg" />
  </a>
</p>

<p align="center">
  <a href="https://youtu.be/sCfvdj49WBw">▶ Talk to your files and manilulate them</a>
  <br/>
  <a href="https://youtu.be/Uf3EWb2hDfs">▶ Your creative private cloud</a>
  <br/>
  <a href="https://youtu.be/RpHp0OEa_o8">▶ iOS app walkthtough</a>
</p>

[![Join our Discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white&label=Join%20us&style=for-the-badge)](https://discord.gg/qYXtsMpqMR)

This is Voltaserve's iOS and iPadOS app, it’s fully native, optimized for iPad and iPhone, runs beautifully on the Mac, features a slick user interface with real-time updates, and is built using Apple’s flagship framework, SwiftUI.

<img src=".assets/collage-20250528000000.png">

## Usage

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

This is a Swift package, it can be installed using the [Swift Package Manager](https://www.swift.org/documentation/package-manager/) and imported in your code.

The extensible `VoltaserveTouch` SwiftUI view can be used to embed the entire UI in your apps:

```swift
import SwiftUI
import VoltaserveTouch

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            VoltaserveTouch()
        }
    }
}
```

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

Voltaserve Touch is released under the [Business Source License 1.1](LICENSE).
