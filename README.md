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

### Mapping

**.good**swift allows you to easily decode JSON objects from [Alamofire](https://github.com/Alamofire/Alamofire) responses using [Unbox](https://github.com/JohnSundell/Unbox) decoder. You can see examples how to map your model in [Unbox readme](https://github.com/JohnSundell/Unbox/blob/master/README.md).

```swift
import Unbox

struct Foo {
    let origin: String
    let url:    URL
}

extension Foo: Unboxable {
    init(unboxer: Unboxer) throws {
        self.origin = try unboxer.unbox(key: "origin")
        self.url = try unboxer.unbox(key: "url")
    }
}
```

Then you just need to use `unbox` or `unboxArray` functions to decode your model.

```swift
import Alamofire
import GoodSwift

Alamofire.request("https://httpbin.org/get").unbox(completion: { (response: DataResponse<Foo>) in
    switch response.result {
    case .success(let foo):
        // Decoded object
    case .failure(let error):
        // Handle error
    }
})
```

### Logging

Automatic logging is enabled when there is `Active Compilation Conditions` flag `DEBUG` defined in project's `Build Settings`. If you have added **.good**swift using [CocoaPods](http://cocoapods.org) you need to add flag `DEBUG` manually into `Active Compilation Conditions` in **.good**swift pod `Build Settings`. If you don't want to add this flag manually after each `pod install` you just need to add this script at the end of your `Podfile`.

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'GoodSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
                    else
                    config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = ''
                end
            end
        end
    end
end
```
#### Log level
You can choose logging level by setting `logLevel` static variable from `DataRequest` class. For now you can choose from these logging levels:
- error - prints only when error occurs
- info (default) - prints request url with response status and error when occurs
- verbose - prints everything including request body and response object

### Chain animations

**.good**swift allows you to easily chain UIView animations.

```swift
UIView.animationChain.animate(withDuration: 2) {
    view.alpha = 0.0
}.animate(withDuration: 2) {
    view.alpha = 1.0
}.start {
    debugPrint("Animation finished")
}
```

### LinkedList implementation

**.good**swift allows you to use default implementation of LinkedList (Queue, FIFO).
[Wiki](https://en.wikipedia.org/wiki/Linked_list)

```swift
let queue = LinkedList<Int>()

print(queue.isEmpty)            // true

queue.push(1)                   // [1]
queue.push(2)                   // [1, 2]
queue.push(3)                   // [1, 2, 3]

print(queue.contains(1))        // true
print(queue.filter { $0 > 1 })  // [2, 3]
print(queue.map { $0 + 2 })     // [3, 4, 5]
print(queue.pop())              // Optional(1)
print(queue.pop())              // Optional(2)
print(queue.isEmpty)            // false
print(queue.peak())             // Optional(3)
print(queue.pop())              // Optional(3)
print(queue.isEmpty)            // true
```


## Author

Marek Spalek, marek.spalek@goodrequest.com

## License

**.good**swift is available under the MIT license. See the LICENSE file for more info.
