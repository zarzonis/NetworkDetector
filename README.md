# NetworkDetector

[![Version](https://img.shields.io/cocoapods/v/NetworkDetector.svg?style=flat)](https://cocoapods.org/pods/NetworkDetector)
[![License](https://img.shields.io/cocoapods/l/NetworkDetector.svg?style=flat)](https://cocoapods.org/pods/NetworkDetector)
[![Platform](https://img.shields.io/cocoapods/p/NetworkDetector.svg?style=flat)](https://cocoapods.org/pods/NetworkDetector)


## Requirements
* iOS 12
* Swift 4.2

## Installation

NetworkDetector is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NetworkDetector'
```

## Example

An example project is included with this repo. To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

```Swift
let networkDetector = NetworkDetector()

networkDetector.reachableHandler = {
    print("Internet connection is active")
}

networkDetector.unreachableHandler = {
    print("Internet connection is down")
}

do {
    try networkDetector.startMonitoring()
} catch let error {
    print(error.localizedDescription)
}

```

## Author

Spyros Zarzonis, spyroszarzonis@gmail.com

## License

NetworkDetector is available under the MIT license. See the LICENSE file for more info.
