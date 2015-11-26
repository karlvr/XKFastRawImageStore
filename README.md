# XKFastRawImageStore

[![CI Status](http://img.shields.io/travis/Karl von Randow/XKFastRawImageStore.svg?style=flat)](https://travis-ci.org/karlvr/XKFastRawImageStore)
[![Version](https://img.shields.io/cocoapods/v/XKFastRawImageStore.svg?style=flat)](http://cocoapods.org/pods/XKFastRawImageStore)
[![License](https://img.shields.io/cocoapods/l/XKFastRawImageStore.svg?style=flat)](http://cocoapods.org/pods/XKFastRawImageStore)
[![Platform](https://img.shields.io/cocoapods/p/XKFastRawImageStore.svg?style=flat)](http://cocoapods.org/pods/XKFastRawImageStore)

XKFastRawImageStore provides a way to read and write images in a format that is most efficient for
loading and displaying using Core Animation.

It is based on work in [Path Fast Image Cache](https://github.com/path/FastImageCache). XKFastRawImageStore has an easier
to remember name and a simpler API for creating and then displaying images, fast. See [Path Fast Image Cache](https://github.com/path/FastImageCache)
for an excellent explanation of how this works.

XKFastRawImageStore writes each image to its own file, so each image may have its own size and other attributes.

XKFastRawImageStore is entirely synchronous. You may use it on any queue, including concurrently, once you have set it up.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

XKFastRawImageStore is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "XKFastRawImageStore"
```

## Author

Karl von Randow, karl@xk72.com

## License

XKFastRawImageStore is available under the MIT license. See the LICENSE file for more info.
