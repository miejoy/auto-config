//
//  ConfigKey.swift
//  
//
//  Created by 黄磊 on 2022/10/15.
//

import Foundation

/// 配置使用 key
public struct ConfigKey<Value>: Hashable, CustomStringConvertible, Sendable {
    let name: String
    
    /// 初始化配置 key
    public init(_ name: String = "") {
        self.name = name
    }
    
    public var description: String {
        "\(name)<\(String(describing: Value.self).replacingOccurrences(of: "()", with: "Void"))>"
    }
}

/// 配置使用 KeyPath
public struct ConfigKeyPath<Value>: Hashable, CustomStringConvertible, Sendable {
    var prevPaths: [String]
    var key: ConfigKey<Value>
    
    public init(prevPaths: [String], key: ConfigKey<Value>) {
        self.prevPaths = prevPaths
        self.key = key
    }
        
    public var description: String {
        prevPaths.joined(separator: ".") + "." + key.description
    }
}

extension ConfigKey where Value == String {
    /// 拼接下一级 key
    public func append<NextValue>(_ key: ConfigKey<NextValue>) -> ConfigKeyPath<NextValue> {
        .init(prevPaths: [name], key: key)
    }
}

extension ConfigKeyPath where Value == String {
    /// 拼接下一级 key
    public func append<NextValue>(_ key: ConfigKey<NextValue>) -> ConfigKeyPath<NextValue> {
        .init(prevPaths: prevPaths + [self.key.name] , key: key)
    }
}

/// 任意配置 key，仅为方便使用
public typealias AnyConfigKey = ConfigKey<Any>
