//
//  LoginHandler.swift
//  Genome
//
//  Created by Matt Gioe on 6/28/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

/**
 User's login status
 
 - LoggedOut: User is logged out
 - LoggedIn: User is logged in
 */

enum LoginStatus : Int {
    
    //only two possible statuses
    case LoggedOut = 0
    case LoggedIn = 1
    
    //determine what the initial view controller is for the delegate when the app launches
    var associatedViewController: UIViewController {
        switch self {
        case LoggedIn:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeView") as UIViewController
            return viewController
        default:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginView") as UIViewController
            return viewController
        }
    }
    
}

struct User {
    let defaults = NSUserDefaults.standardUserDefaults()

    //could have used core data here but using the defaults instead so we don't overcomplicate things. defaults only needs to tell us whether the user is logged in or not so we simulate a boolean and compute the property as we go
    
    var loginStatus : LoginStatus {
        get {
            if defaults.objectForKey("Login Status") != nil {
                return LoginStatus.init(rawValue: defaults.integerForKey("Login Status"))!
            } else {
                return .LoggedOut
            }
        }
        set(newLoginStatus){
            defaults.setInteger(newLoginStatus.rawValue, forKey: "Login Status")
        }
    }
}

