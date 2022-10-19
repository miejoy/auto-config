# AutoConfig

AutoConfig 主要是为其他模块提供自动加载主模块设置的配置信息。

[![Swift](https://github.com/miejoy/auto-config/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/auto-config/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/auto-config/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/auto-config)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-5.4-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 13.0+ / macOS 10.15+
- Xcode 12.0+
- Swift 5.2+

## 简介

该模块会自动读取加载主项目中配置信息，会按照如下顺序加载：
1、先读取项目中 config.plist 配置的信息
2、载读取主项目中 UserConfig 配置的信息

## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖:

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/auto-config.git", from: "0.1.0"),
]
```

## 使用

### 添加自动配置

```swift
import AutoConfig

final class UserConfig: ConfigProtocol {
    static var configs: [String : Any] = [
        .init(.appId, "123456789")
    ]
}
```

### 使用配置信息

```swift
import AutoConfig

let appId = Config.value(for: ConfigKey.kAppId, "")
```

## 作者

Raymond.huang: raymond0huang@gmail.com

## License

AutoConfig is available under the MIT license. See the LICENSE file for more info.

