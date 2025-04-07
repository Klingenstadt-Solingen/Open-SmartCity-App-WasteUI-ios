// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let oscaWasteVersion = Version("1.4.1")
let oscaSafariViewVersion = Version("1.1.0")

let package = Package(
  name: "OSCAWasteUI",
  defaultLocalization: "de",
  platforms: [.iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCAWasteUI",
      targets: ["OSCAWasteUI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // OSCAWaste
    packageLocal ? .package(path: "../OSCAWaste") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscawaste-ios.git",
             .upToNextMinor(from: oscaWasteVersion)),
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
    // OSCASafariView
    packageLocal ? .package(path: "../OSCASafariView") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscasafariview-ios.git",
             .upToNextMinor(from: oscaSafariViewVersion)),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCAWasteUI",
      dependencies: [.product(name: "OSCAWaste",
                              package: packageLocal ? "OSCAWaste" : "oscawaste-ios"),
                     /* OSCAEssentials */
                     .product(name: "OSCAEssentials",
                              package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                     .product(name: "OSCASafariView",
                              package: packageLocal ? "OSCASafariView" : "oscasafariview-ios")],
      path: "OSCAWasteUI/OSCAWasteUI",
      exclude:["Info.plist",
               "SupportingFiles"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "OSCAWasteUITests",
      dependencies: ["OSCAWasteUI",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")],
      path: "OSCAWasteUI/OSCAWasteUITests",
      exclude:["Info.plist"],
      resources: [.process("Resources")],
      swiftSettings: [.define("ENABLE_SOMETHING",
                              .when(configuration: .debug))]
    ),
  ]
)
