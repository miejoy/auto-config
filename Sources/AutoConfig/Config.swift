//
//  Config.swift
//  
//
//  Created by 黄磊 on 2022/7/4.
//  Copyright © 2022 Miejoy. All rights reserved.
//

import Foundation

let kBundleName = "CFBundleName"

/// 配置协议
public protocol ConfigProtocol {
    static var configs : [String:Any] { get }
}


/// 配置参数列表
public struct ConfigKey {
    
    /// App id
    public static let kAppId            = "kAppId"
}

final public class Config {
    
    public static func add(with dic: [String:Any]) {
        g_appConfig.merge(dic) { (old, new) -> Any in
            if old is [String:Any] && type(of: old) == type(of: new) {
                var oldNew = old as! [String:Any]
                oldNew.merge(new as! [String:Any]) { (_, last) in last }
                return oldNew
            } else {
                return new
            }
        }
    }
    
    /// 获取配置中 key 对应的值
    public static func valueOf(_ key: String) -> Any? {
        return g_appConfig[key]
    }
    
    /// 获取配置中 key 对应类型的值
    public static func valueOf<T>(_ key: String, _ defVaule: T) -> T {
        return g_appConfig[key] as? T ?? defVaule
    }
    
    /// 获取配置中 keyPath 对应类型的值，以 . 分割
    public static func valueOf<T>(keyPath: String, _ defVaule: T) -> T {
        var arrPath = keyPath.split(separator: ".")
        guard let lastKey = arrPath.popLast() else {
            return defVaule
        }
        var theDic = g_appConfig
        for aKey in arrPath {
            if let aDic = theDic[String(aKey)] as? [String:Any] {
                theDic = aDic
            } else {
                return defVaule
            }
        }
        return theDic[String(lastKey)] as? T ?? defVaule
    }
}


extension Config {
    public static func combine(value: String?, otherValue: String?) -> String? {
        guard let value = value else { return nil }
        guard let otherValue = otherValue else { return nil }
        return value + otherValue
    }
}


/// 所有配置参数
var g_appConfig : [String:Any] = {

    var aAppConfig : [String:Any] = [:]
    
    // 读取项目配置文件
    if let filePath = Bundle.main.path(forResource: "config", ofType: "plist"),
        FileManager.default.fileExists(atPath: filePath),
        let data = FileManager.default.contents(atPath: filePath) {
        // 从plist 读取数据
        var plistFormat = PropertyListSerialization.PropertyListFormat.xml
        if let dic = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &plistFormat) as? [String:Any] {
            aAppConfig.merge(dic) { (old, new) -> Any in
                if old is [String:Any] && type(of: old) == type(of: new) {
                    var oldNew = old as! [String:Any]
                    oldNew.merge(new as! [String:Any]) { (_, last) in last }
                    return oldNew
                } else {
                    return new
                }
            }
        }
    }
    
    // 读取 main bundle 对应类
    var mainBundle = Bundle.main
    print(Bundle.main.bundleIdentifier ?? "")
    if let bundleIdentifier = Bundle.main.bundleIdentifier,
        bundleIdentifier == "com.apple.dt.xctest.tool" {
        // 单元测试使用的 main bundle 不正确
        for aBundle in Bundle.allBundles {
            print(aBundle.resourcePath ?? "")
            if aBundle.resourcePath?.contains(".xctest") ?? false {
                if let bundleName = aBundle.infoDictionary?[kBundleName] as? String {
                    mainBundle = aBundle
                }
                break
            }
        }
    }
    if let bundleName = mainBundle.infoDictionary?[kBundleName] as? String {
        print(bundleName)
        let useName = bundleName.replacingOccurrences(of: " ", with: "_")
        if let aClass = mainBundle.classNamed(useName + ".UserConfig"),
            let aConfigClass = aClass as? ConfigProtocol.Type {
            aAppConfig.merge(aConfigClass.configs) { (old, new) -> Any in
                if old is [String:Any] && type(of: old) == type(of: new) {
                    var oldNew = old as! [String:Any]
                    oldNew.merge(new as! [String:Any]) { (_, last) in last }
                    return oldNew
                } else {
                    return new
                }
            }
        }
    }
    return aAppConfig
}()
