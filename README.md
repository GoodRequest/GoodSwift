![.goodswift](https://www.dropbox.com/s/n7scwrla13ym870/goodswift.png?dl=1)


[![Version](https://img.shields.io/cocoapods/v/GoodSwift.svg?style=flat)](http://cocoapods.org/pods/GoodSwift)
[![License](https://img.shields.io/cocoapods/l/GoodSwift.svg?style=flat)](http://cocoapods.org/pods/GoodSwift)
[![Platform](https://img.shields.io/cocoapods/p/GoodSwift.svg?style=flat)](http://cocoapods.org/pods/GoodSwift)

Some good swift extensions, handfully crafted by GoodRequest team.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Author](#author)
- [License](#license)

## Requirements

- iOS 9.0+
- Xcode 8.2+
- Swift 3.0+

## Installation

**.good**swift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GoodSwift"
```

## Usage

**.good**mapping allows you to easily decode JSON objects from [Alamofire](https://github.com/Alamofire/Alamofire) responses using [Unbox](https://github.com/JohnSundell/Unbox) decoder. You can see examples how to map your model in [Unbox readme](https://github.com/JohnSundell/Unbox/blob/master/README.md). Then you just need to use `unbox` or `unboxArray` functions to decode your model.

```swift
Alamofire.request("https://httpbin.org/get").unbox(completion: { response in
    switch response.result {
    case .success(let object):
        // decoded object
    case .failure(let error):
        // Handle error
    }
})
```

## Author

Marek Spalek, marek.spalek@goodrequest.com

## License

Smaky is available under the MIT license. See the LICENSE file for more info.
