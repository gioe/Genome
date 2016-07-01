//
//  GenomeTests.swift
//  GenomeTests
//
//  Created by Matt Gioe on 6/28/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import XCTest
@testable import Genome

class GenomeUserTests: XCTestCase {
    var user = User()

    func testUserInit(){
        user.loginStatus = .LoggedIn
        XCTAssertNotNil(user)
    }
    
    func testReturnCorrectVCForLoggedOutStatus(){
        user.loginStatus = .LoggedOut
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginView") as UIViewController
        
        XCTAssertEqual(user.loginStatus.associatedViewController.nibName, viewController.nibName)
    }
    
    func testReturnCorrectVCForLoggedInStatus(){
        user.loginStatus = .LoggedIn
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeView") as UIViewController
        
        XCTAssertEqual(user.loginStatus.associatedViewController.nibName, viewController.nibName)
    }
   
    
}
