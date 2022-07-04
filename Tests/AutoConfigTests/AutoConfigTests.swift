//
//  Config.swift
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
        
        XCTAssertEqual(configs["testConfig"] as? String, "test123")
        XCTAssertEqual(Config.valueOf(ConfigKey.testConfig, ""), "test123")
        XCTAssertEqual(Config.valueOf(ConfigKey.testConfig) as? String, "test123")
    }
    
    func testValueOfKeyPath() {
        
        let group = "group"
        let key = "key"
        let value = "value"
        let dic : [String:Any] = [
            group : [
                key : value
            ]
        ]
        Config.add(with: dic)
        
        let result = Config.valueOf(keyPath: "\(group).\(key)", "")
        
        XCTAssertEqual(result, value)
    }
    
    func testCombine() {
        XCTAssertEqual(Config.combine(value: "value", otherValue: "otherValue"), "valueotherValue")
    }
}

extension ConfigKey {
    static var testConfig = "testConfig"
}

class UserConfig: ConfigProtocol {

    static var configs: [String : Any] = [

        "testConfig" : "test123"
    ]
}
