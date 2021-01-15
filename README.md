# Devlibs

A Swift-based library created by Charles Hsieh.

### Table of Content

- Combine
    - Extended `UIControl` with support for pub/sub events handling. 
        - New publishers: `ControlEvent`, `ControlProperty`, `TargetAction`
- Logging
- Networking
    - HttpClient: A lightweight HTTP-client framework featuring:
        1. Multiple pre-defined interfaces (`HttpResource` and `Request`).
        2. Modularizable modifiers of the `URLRequest` and the received `Data`.
        3. Fully integrated logging functions using `OSLog`.
        4. Supporting the Combine framework.
    - `RemoteImageLoader`
- Graphics
    - `ListScrollView`
    - Helpers
        - `NibLoadable`
        - `Storyboarded` 
    - Extensions: UIKit-dominant extensions
- Utils
    - `Benchmark` provides a static function to measure execution time of any synchronous operation.
    - `Delegation` is a closure wrapper that shadows the weak-reference declaration, helping with avoiding potentially causing retain cycles when dealing with closures.
    - `Protected` is a property-wrapper providing thread-safe operations on the wrapped property.
    - `Cache`
    - `CallbackQueue`

## Requirement

- Xcode 11.4+
- iOS 11+
- macOS 10.12+
- tvOS 11+
- watchOS 4+

## Contact

- Charles Hsieh
- charlous167@gmail.com
