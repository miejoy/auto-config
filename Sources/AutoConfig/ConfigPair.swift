//
//  ConfigPair.swift
//  
//
//  Created by 黄磊 on 2022/10/16.
//

import Foundation

/// 配置对
public struct ConfigPair: Hashable {
    let key: AnyHashable
    let name: String
    let value: Any
    let valueType: Any.Type
    
    init(key: AnyHashable, name: String, value: Any, valueType: Any.Type) {
        self.key = key
        self.name = name
        self.value = value
        self.valueType = valueType
    }
    
    /// 创建配置对
    ///
    /// - Parameter configKey: 配置对应 key
    /// - Parameter configKey: 配置对应 值
    /// - Returns Self: 返回构造好的配置对
    public static func make<Value>(_ configKey: ConfigKey<Value>, _ value: Value) -> Self {
        return self.init(key: AnyHashable(configKey), name: configKey.name, value: value, valueType: Value.self)
    }
    
    public static func make<Value>(keyPath configKeyPath: ConfigKeyPath<Value>, _ value: Value) -> Self {
        return configKeyPath.prevPaths.reversed().reduce(ConfigPair.make(configKeyPath.key, value)) { partialResult, path in
            ConfigPair.group(path, [partialResult])
        }
    }
    
    public static func group(_ groupKey: String, _ value: [ConfigPair]) -> Self {
        let configKey = ConfigKey<[ConfigPair]>(groupKey)
        return self.init(key: AnyHashable(configKey), name: configKey.name, value: value, valueType: Set<ConfigPair>.self)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key.hashValue == rhs.key.hashValue
    }
}
