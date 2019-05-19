//
//  WikipediaDeepLinkTests.swift
//  WikipediaDeepLinkTests
//
//  Created by Kaan Baris BAYRAK on 19.05.2019.
//  Copyright © 2019 Kaan Baris Bayrak. All rights reserved.
//

import XCTest
@testable import WikipediaDeepLink

class WikipediaDeepLinkTests: XCTestCase {
    
    var locationVC : LocationsViewController!
    
    override func setUp() {
        self.locationVC = LocationsViewController()
    }

    func testDeepLinkUrl(){
        let urlString = locationVC.generateDeepLink(lat: 10.2, lon: -5.8)
        XCTAssertEqual(urlString, "wikipedia://places?lat=10.2&lon=-5.8")
    }
    
    func testDeepLinkValidity(){
        let urlString = locationVC.generateDeepLink(lat: 10.2, lon: -5.8)
        let url = URL(string: urlString)
        XCTAssertNotNil(url)
        let canOpenUrl = UIApplication.shared.canOpenURL(url!)
        XCTAssertTrue(canOpenUrl)
    }
    
}
