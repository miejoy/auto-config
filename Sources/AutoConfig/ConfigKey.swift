//
//  ConfigKey.swift
//  
//
//  Created by 黄磊 on 2022/10/15.
//

import Foundation

/// 配置使用 key
public struct ConfigKey<Data>: Hashable, CustomStringConvertible {
    let configId: String
    
    /// 初始化配置 key
    public init(_ configId: String = "") {
        self.configId = configId
    }
    
    public var description: String {
        "\(configId)<\(String(describing: Data.self).replacingOccurrences(of: "()", with: "Void"))>"
    }
}

/// 配置使用 KeyPath
public struct ConfigKeyPath<Data>: Hashable, CustomStringConvertible {
    var prevPaths: [String]
    var key: ConfigKey<Data>
        
    public var description: String {
        prevPaths.joined(separator: ".") + "." + key.description
    }
}

extension ConfigKey where Data == String {
    /// 拼接下一级 key
    public func append<Data>(_ key: ConfigKey<Data>) -> ConfigKeyPath<Data> {
        .init(prevPaths: [configId], key: key)
    }
}

extension ConfigKeyPath where Data == String {
    /// 拼接下一级 key
    public func append<Data>(_ key: ConfigKey<Data>) -> ConfigKeyPath<Data> {
        .init(prevPaths: prevPaths + [self.key.configId] , key: key)
    }
}

/// 任意配置 key，仅为方便使用
public typealias AnyConfigKey = ConfigKey<Any>
