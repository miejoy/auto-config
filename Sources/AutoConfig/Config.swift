//
//  Config.swift
//  
//
//  Created by 黄磊 on 2022/7/4.
//  Copyright © 2022 Miejoy. All rights reserved.
//

import Foundation
import CoreFoundation

let kBundleName = "CFBundleName"

/// 配置协议
public protocol ConfigProtocol {
    /// 重新这个类设置各种配置
    static var configs : Set<ConfigPair> { get }
}

public extension ConfigKey where Data == String {
    /// 应用 ID
    static let appId = ConfigKey<String>("appId")
}

final public class Config {
    /// 添加配置，建议只在启动阶段使用
    ///
    /// - Parameter value: 设置配置对应的值
    /// - Parameter key: 设置配置对应的 key
    public static func set<Data>(_ value: Data, for key: ConfigKey<Data>) {
        g_appConfig[AnyHashable(key)] = value
    }
    
    /// 读取对应 key 的配置
    ///
    /// - Parameter key: 读取配置使用的 key
    /// - Returns Data?: 返回需要的配置值，如果不存在返回 nil
    public static func value<Data>(for key: ConfigKey<Data>) -> Data? {
        g_appConfig[AnyHashable(key)] as? Data
    }
    
    /// 读取对应 key 的配置
    ///
    /// - Parameter key: 读取配置使用的 key
    /// - Parameter defaultValue: 读取失败使用的默认值
    /// - Returns Data: 返回需要的配置值
    @inlinable
    public static func value<Data>(for key: ConfigKey<Data>, _ defaultValue: @autoclosure () -> Data) -> Data {
        value(for: key) ?? defaultValue()
    }
    
    /// 通过 ConfigKeyPath 添加配置，建议只在启动阶段使用
    ///
    /// - Parameter value: 设置配置对应的值
    /// - Parameter keyPath: 设置配置对应的 KeyPath
    public static func set<Data>(_ value: Data, with keyPath: ConfigKeyPath<Data>) {
        let configPairSet = keyPath.prevPaths.reversed().reduce(Set<ConfigPair>([ConfigPair(keyPath.key, value)])) { partialResult, configId in
            Set<ConfigPair>([ConfigPair(ConfigKey<Set<ConfigPair>>(configId), partialResult)])
        }
        merge(&g_appConfig, with: configPairSet)
    }
    
    /// 读取对应 keyPath 的配置
    ///
    /// - Parameter keyPath: 读取配置使用的 KeyPath
    /// - Returns Data?: 返回需要的配置值，如果不存在返回 nil
    public static func value<Data>(with keyPath: ConfigKeyPath<Data>) -> Data? {
        var topDic: [AnyHashable: Any]? = g_appConfig
        _ = keyPath.prevPaths.first { configId in
            if let nextDic = topDic?[AnyHashable(ConfigKey<[AnyHashable:Any]>(configId))] as? [AnyHashable: Any] {
                topDic = nextDic
                return false
            } else {
                topDic = nil
                return true
            }
        }
        return topDic?[AnyHashable(keyPath.key)] as? Data
    }
    
    /// 读取对应 keyPath 的配置
    ///
    /// - Parameter keyPath: 读取配置使用的 KeyPath
    /// - Parameter defaultValue: 读取失败使用的默认值
    /// - Returns Data?: 返回需要的配置值，如果不存在返回 nil
    @inlinable
    public static func value<Data>(with keyPath: ConfigKeyPath<Data>, _ defaultValue: @autoclosure () -> Data) -> Data {
        value(with: keyPath) ?? defaultValue()
    }
}

var g_appConfig : [AnyHashable: Any] = {
    var aAppConfig : [AnyHashable: Any] = [:]
    
    // 读取项目配置文件
    if let filePath = Bundle.main.path(forResource: "configs", ofType: "json") {
        let configPairs = Config.loadConfigsOnJsonFile(filePath)
        Config.merge(&aAppConfig, with: configPairs)
    } else if let filePath = Bundle.main.path(forResource: "configs", ofType: "plist") {
        let configPairs = Config.loadConfigsOnPlistFile(filePath)
        Config.merge(&aAppConfig, with: configPairs)
    }
    
    // 读取 main bundle 对应类
    let (mainBundle, mainBundleName) = Config.getMainBundle()
    if let bundleName = mainBundleName {
        if let aClass = mainBundle.classNamed(bundleName + ".UserConfig"),
            let aConfigClass = aClass as? ConfigProtocol.Type {
            Config.merge(&aAppConfig, with: aConfigClass.configs)
        }
    }
    
    return aAppConfig
}()


extension Config {
    
    static func getMainBundle() -> (Bundle, String?) {
        var mainBundle = Bundle.main
        var mainBundleName = mainBundle.infoDictionary?[kBundleName] as? String
        if let bundleIdentifier = Bundle.main.bundleIdentifier,
            bundleIdentifier == "com.apple.dt.xctest.tool" {
            // 单元测试使用的 main bundle 不正确
            for aBundle in Bundle.allBundles {
                if aBundle.bundlePath.hasSuffix(".xctest") {
                    if let bundleName = aBundle.infoDictionary?[kBundleName] as? String {
                        mainBundle = aBundle
                        mainBundleName = bundleName.replacingOccurrences(of: " ", with: "_")
                    } else if let aClass = aBundle.principalClass {
                        mainBundle = aBundle
                        if let firstName = String(reflecting: aClass).split(separator: ".").first {
                            var bundleName = String(firstName)
                            if !bundleName.hasSuffix("Tests") {
                                bundleName += "Tests"
                            }
                            mainBundleName = bundleName
                        }
                    }
                    break
                }
            }
        }
        return (mainBundle, mainBundleName)
    }
    
    static func loadConfigsOnJsonFile(_ filePath: String) -> Set<ConfigPair> {
        guard FileManager.default.fileExists(atPath: filePath),
              let data = FileManager.default.contents(atPath: filePath) else {
            return []
        }
        
        if let dic = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any] {
            return convertDicToConfigPairSet(dic)
        }
        return []
    }
    
    static func loadConfigsOnPlistFile(_ filePath: String) -> Set<ConfigPair> {
        guard FileManager.default.fileExists(atPath: filePath),
              let data = FileManager.default.contents(atPath: filePath) else {
            return []
        }
        
        var plistFormat = PropertyListSerialization.PropertyListFormat.xml
        if let dic = try? PropertyListSerialization.propertyList(from: data, options: [.mutableContainersAndLeaves], format: &plistFormat) as? [String:Any] {
            return convertDicToConfigPairSet(dic)
        }
        return []
    }
    
    static func convertDicToConfigPairSet(_ dic: [String: Any]) -> Set<ConfigPair> {
        dic.reduce(into: Set<ConfigPair>()) { partialResult, pair in
            if let string = pair.value as? String {
                partialResult.insert(.init(.init(pair.key), string))
            } else if let int = pair.value as? Int {
                // 可能是 NSNumber 的 bool
                if let number = pair.value as? NSNumber,
                   type(of: number) == type(of: NSNumber(booleanLiteral: true)) {
                    partialResult.insert(.init(.init(pair.key), number.boolValue))
                } else {
                    partialResult.insert(.init(.init(pair.key), int))
                }
            } else if let bool = pair.value as? Bool {
                partialResult.insert(.init(.init(pair.key), bool))
            } else if let double = pair.value as? Double {
                partialResult.insert(.init(.init(pair.key), double))
            } else if let map = pair.value as? [String:Any] {
                partialResult.insert(.init(.init(pair.key), convertDicToConfigPairSet(map)))
            } else if let array = pair.value as? [Any] {
                if let arrayString = array as? [String] {
                    partialResult.insert(.init(.init(pair.key), arrayString))
                } else if let arrayInt = array as? [Int] {
                    partialResult.insert(.init(.init(pair.key), arrayInt))
                } else if let arrayBool = array as? [Bool] {
                    partialResult.insert(.init(.init(pair.key), arrayBool))
                } else if let arrayDouble = array as? [Double] {
                    partialResult.insert(.init(.init(pair.key), arrayDouble))
                }
            }
        }
    }
    
    static func merge(_ appConfig: inout [AnyHashable: Any], with configPairs: Set<ConfigPair>) {
        configPairs.forEach { configPair in
            if let nextData = configPair.data as? Set<ConfigPair> {
                // 递归
                var nextConfidDic: [AnyHashable: Any] = appConfig[configPair.key] as? [AnyHashable: Any] ?? [:]
                merge(&nextConfidDic, with: nextData)
                appConfig[ConfigKey<[AnyHashable:Any]>(configPair.configId)] = nextConfidDic
            } else {
                appConfig[configPair.key] = configPair.data
            }
        }
    }
}
