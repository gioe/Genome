//
//  ViewController.swift
//  Genome
//
//  Created by Matt Gioe on 6/28/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import FBSDKLoginKit

private let HomeViewSegue = "pushHomeView"

class GNMLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    var sessionUser = GNMUser()
    
    @IBOutlet weak var loginButton: FBSDKLoginButton! {
        didSet {
            loginButton.layer.cornerRadius = 10
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil){
        } else {
            self.view.addSubview(loginButton)
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if result.token != nil{
            loginButton.hidden = true
            sessionUser.loginStatus = .LoggedIn
             self.presentViewController(sessionUser.loginStatus.associatedViewController, animated: true, completion: nil)
        } else {
            displayLoginError()
        }
       
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    /**
     Displays an alert view if Facebook login should fail
     */
    
    func displayLoginError(){
        
        //display an error alert in case facebook login fails
        let alert = UIAlertController.init(title: "Genome", message: "There seems to have been a problem signing in with Facebook. Please try again later." , preferredStyle: .Alert)
        let dismissAction = UIAlertAction.init(title: "OK!", style: .Cancel, handler: { (action) in
        })
        alert.addAction(dismissAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

