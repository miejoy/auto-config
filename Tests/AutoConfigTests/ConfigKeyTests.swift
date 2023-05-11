//
//  ConfigKeyTests.swift
//  
//
//  Created by 黄磊 on 2022/10/17.
//

import XCTest
@testable import AutoConfig

final class ConfigKeyTests: XCTestCase {
    
    func testSameConfigKey() {
        let key1 = ConfigKey<String>()
        let key2 = ConfigKey<String>()
        
        XCTAssertEqual(key1, key2)
        XCTAssertEqual(AnyHashable(key1), AnyHashable(key2))
        XCTAssertEqual(key1.description, key2.description)
        
        let key3 = ConfigKey<String>("key")
        let key4 = ConfigKey<String>("key")
        
        XCTAssertEqual(key3, key4)
        XCTAssertEqual(AnyHashable(key3), AnyHashable(key4))
        XCTAssertEqual(key3.description, key4.description)
    }
    
    func testDifferentConfigKey() {
        let key1 = ConfigKey<String>()
        let key2 = ConfigKey<Int>()
        
        XCTAssertNotEqual(AnyHashable(key1), AnyHashable(key2))
        XCTAssertNotEqual(key1.description, key2.description)
        
        let key3 = ConfigKey<Int>()
        let key4 = ConfigKey<Int32>()
        
        XCTAssertNotEqual(AnyHashable(key3), AnyHashable(key4))
        XCTAssertNotEqual(key3.description, key4.description)
    }
    
    func testKeyPath() {
        let key1 = ConfigKey<String>("key1")
        let key2 = ConfigKey<String>("key2")

        let keyPath = key1.append(key2).append(ConfigKey<Int>())
        
        XCTAssertEqual(keyPath.description, "key1.key2.<Int>")
    }
    
    func testConfigPairWithKeyPath() {
        let pair1 = ConfigPair.make(keyPath: .webAPIDeviceRegister, "test1")
        let pair2 = ConfigPair.group("WebAPI", [.make(.deviceRegister, "test2")])
        
        XCTAssertEqual(pair1, pair2)
        
        XCTAssertEqual(pair1.hashValue, pair2.hashValue)
    }
    
    func testVoidConfigKey() {
        let name = "name"
        let key1 = ConfigKey<Void>(name)
        // let key2 = ConfigKey<[Void]>(name)
        // let key3 = ConfigKey<[String:Void]>(name)
        // let key4 = ConfigKey<[String:(Void, Void)]>(name)
        
        XCTAssertEqual(key1.description, "name<Void>")
        // XCTAssertEqual(key2.description, "name<[Void]>")
        // XCTAssertEqual(key3.description, "name<[String:Void]>")
        // XCTAssertEqual(key4.description, "name<[String:(Void, Void)]>")
    }
}
