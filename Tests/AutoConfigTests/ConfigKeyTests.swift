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
}
