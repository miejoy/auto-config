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
    let configId: String
    let data: Any
    let dataType: Any.Type
    
    init(key: AnyHashable, configId: String, data: Any, dataType: Any.Type) {
        self.key = key
        self.configId = configId
        self.data = data
        self.dataType = dataType
    }
    
    /// 创建配置对
    ///
    /// - Parameter configKey: 配置对应 key
    /// - Parameter configKey: 配置对应 值
    /// - Returns Self: 返回构造好的配置对
    public static func make<Data>(_ configKey: ConfigKey<Data>, _ data: Data) -> Self {
        return self.init(key: AnyHashable(configKey), configId: configKey.configId, data: data, dataType: Data.self)
    }
    
    public static func make<Data>(keyPath configKeyPath: ConfigKeyPath<Data>, _ data: Data) -> Self {
        return configKeyPath.prevPaths.reversed().reduce(ConfigPair.make(configKeyPath.key, data)) { partialResult, path in
            ConfigPair.group(path, [partialResult])
        }
    }
    
    public static func group(_ groupKey: String, _ data: [ConfigPair]) -> Self {
        let configKey = ConfigKey<[ConfigPair]>(groupKey)
        return self.init(key: AnyHashable(configKey), configId: configKey.configId, data: data, dataType: Set<ConfigPair>.self)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key.hashValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key.hashValue == rhs.key.hashValue
    }
}

