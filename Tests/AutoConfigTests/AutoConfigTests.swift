//
//  AutoConfigTests.swift
//
//
//  Created by 黄磊 on 2022/7/4.
//  Copyright © 2022 Miejoy. All rights reserved.
//

import XCTest
@testable import AutoConfig

final class AutoConfigTests: XCTestCase {
        
    func testUserConfig() {
        let configs = g_appConfig
        
        XCTAssertEqual(configs[AnyHashable(AnyConfigKey.testConfig)] as? String, "test123")
        XCTAssertEqual(Config.value(for: .testConfig), "test123")
        
        XCTAssertEqual(Config.value(with: .webAPIDeviceRegister), "Device.Register1")
    }
    
    func testLoadConfigOnJson() {
        let resourceBundle = Bundle.module
        let jsonFilePath = resourceBundle.path(forResource: "configs", ofType: "json")!
        let configPairs = Config.loadConfigsOnJsonFile(jsonFilePath)
        
        let stringKey = ConfigKey<String>("string_key")
        let stringConfig = configPairs.first { $0.key == AnyHashable(stringKey) }
        XCTAssertEqual(stringConfig?.data as? String, "test")
        
        let intKey = ConfigKey<Int>("int_key")
        let intConfig = configPairs.first { $0.key == AnyHashable(intKey) }
        XCTAssertEqual(intConfig?.data as? Int, 1)
        
        let doubleKey = ConfigKey<Double>("double_key")
        let doubleConfig = configPairs.first { $0.key == AnyHashable(doubleKey) }
        XCTAssertEqual(doubleConfig?.data as? Double, 1.1)
        
        let boolKey = ConfigKey<Bool>("bool_key")
        let boolConfig = configPairs.first { $0.key == AnyHashable(boolKey) }
        XCTAssertEqual(boolConfig?.data as? Bool, true)
        
        let mapKey = ConfigKey<[ConfigPair]>("map_key")
        let mapConfig = configPairs.first { $0.key == AnyHashable(mapKey) }
        let mapData = mapConfig!.data as! [ConfigPair]
        let mapSecondKey = ConfigKey<String>("second_string_key")
        let secondConfig = mapData.first  { $0.key == AnyHashable(mapSecondKey) }
        XCTAssertEqual(secondConfig?.data as? String, "second_test")
        
        let arrKey = ConfigKey<[String]>("array_key")
        let arrConfig = configPairs.first { $0.key == AnyHashable(arrKey) }
        XCTAssertEqual(arrConfig?.data as? [String], ["test1", "test2"])
    }
    
    func testLoadConfigOnPlist() {
        let resourceBundle = Bundle.module
        let plistFilePath = resourceBundle.path(forResource: "configs", ofType: "plist")!
        let configPairs = Config.loadConfigsOnPlistFile(plistFilePath)
        
        let stringKey = ConfigKey<String>("string_key")
        let stringConfig = configPairs.first { $0.key == AnyHashable(stringKey) }
        XCTAssertEqual(stringConfig?.data as? String, "test")
        
        let intKey = ConfigKey<Int>("int_key")
        let intConfig = configPairs.first { $0.key == AnyHashable(intKey) }
        XCTAssertEqual(intConfig?.data as? Int, 1)
        
        let doubleKey = ConfigKey<Double>("double_key")
        let doubleConfig = configPairs.first { $0.key == AnyHashable(doubleKey) }
        XCTAssertEqual(doubleConfig?.data as? Double, 1.1)
        
        let boolKey = ConfigKey<Bool>("bool_key")
        let boolConfig = configPairs.first { $0.key == AnyHashable(boolKey) }
        XCTAssertEqual(boolConfig?.data as? Bool, true)
        
        let mapKey = ConfigKey<[ConfigPair]>("map_key")
        let mapConfig = configPairs.first { $0.key == AnyHashable(mapKey) }
        let mapData = mapConfig!.data as! [ConfigPair]
        let mapSecondKey = ConfigKey<String>("second_string_key")
        let secondConfig = mapData.first  { $0.key == AnyHashable(mapSecondKey) }
        XCTAssertEqual(secondConfig?.data as? String, "second_test")
        
        let arrKey = ConfigKey<[String]>("array_key")
        let arrConfig = configPairs.first { $0.key == AnyHashable(arrKey) }
        XCTAssertEqual(arrConfig?.data as? [String], ["test1", "test2"])
    }
    
    func testSetAndGetStringValue() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.stringKey))
        
        XCTAssertNil(Config.value(for: .stringKey))
        
        let stringValue = "test1"
        Config.set(stringValue, for: .stringKey)
        XCTAssertNotNil(Config.value(for: .stringKey))
        XCTAssertEqual(Config.value(for: .stringKey), stringValue)
    }
    
    func testSetAndGetIntValue() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.intKey))
        
        XCTAssertNil(Config.value(for: .intKey))
        
        let intValue = 1
        Config.set(intValue, for: .intKey)
        XCTAssertNotNil(Config.value(for: .intKey))
        XCTAssertEqual(Config.value(for: .intKey), intValue)
    }
    
    func testSetAndGetDoubleValue() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.doubleKey))
        
        XCTAssertNil(Config.value(for: .doubleKey))
        
        let doubleKey = 1.1
        Config.set(doubleKey, for: .doubleKey)
        XCTAssertNotNil(Config.value(for: .doubleKey))
        XCTAssertEqual(Config.value(for: .doubleKey), doubleKey)
    }
    
    func testSetAndGetBoolValue() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.boolKey))
        
        XCTAssertNil(Config.value(for: .boolKey))
        
        let boolKey = true
        Config.set(boolKey, for: .boolKey)
        XCTAssertNotNil(Config.value(for: .boolKey))
        XCTAssertEqual(Config.value(for: .boolKey), boolKey)        
    }
    
    func testSetAndGetKeyPathValue() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.objectKey))
        
        XCTAssertNil(Config.value(for: .objectKey))
        
        let keyPath = ConfigKey<String>.objectKey.append(.stringKey)
        let stringValue = "test2"
        Config.set(stringValue, with: keyPath)
        XCTAssertNotNil(Config.value(with: keyPath))
        XCTAssertEqual(Config.value(with: keyPath), stringValue)
    }
    
    func testSetGetKeyPathNotFound() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.objectKey))
        
        XCTAssertNil(Config.value(for: .objectKey))
        
        let keyPath = ConfigKey<String>.objectKey.append(.intKey)
        XCTAssertNil(Config.value(with: keyPath))
    }
    
    func testGetUseDefault() {
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.stringKey))
        
        XCTAssertNil(Config.value(for: .stringKey))
        let testValue = "testValue"
        XCTAssertEqual(Config.value(for: .stringKey, testValue), testValue)
        
        g_appConfig.removeValue(forKey: AnyHashable(AnyConfigKey.objectKey))
        let keyPath = ConfigKey<String>.objectKey.append(.intKey)
        let intValue = 789
        XCTAssertEqual(Config.value(with: keyPath, intValue), intValue)
    }
}

extension ConfigKey {
    static var testConfig: ConfigKey<String> { .init("testConfig") }
    
    static var stringKey: ConfigKey<String> { .init("stringKey") }
    static var intKey: ConfigKey<Int> { .init("intKey") }
    static var doubleKey: ConfigKey<Double> { .init("doubleKey") }
    static var boolKey: ConfigKey<Bool> { .init("boolKey") }
    
    static var objectKey: ConfigKey<String> { .init("objectKey") }
    
    static var deviceRegister: ConfigKey<String> { .init("deviceRegister") }
}

extension ConfigKeyPath where Data == String {
    static var webAPIDeviceRegister: ConfigKeyPath<String> = .init(prevPaths: ["WebAPI"], key: .deviceRegister)
}

class UserConfig: ConfigProtocol {

    static var configs: [ConfigPair] = [
        .make(.testConfig,  "test123"),
        .make(.appId,       "123"),
        .group("WebAPI", [
            .make(.deviceRegister, "Device.Register")
        ]),
        .make(keyPath: .webAPIDeviceRegister, "Device.Register1"), // 这个将会覆盖前面的
        .make(.appId,       "456") // 这个将会覆盖前面的
    ]
}
