//
//  CustomerLoginViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class CustomerLoginViewController : UIViewController {

  @IBAction func signInCustomer() {
    let interfaceManager = GITInterfaceManager()
    interfaceManager.delegate = self
    GITClient.sharedInstance().delegate = self
    interfaceManager.startSignIn()
  }
}

extension CustomerLoginViewController : GITInterfaceManagerDelegate, GITClientDelegate {

  func client(client: GITClient!, didFinishSignInWithToken token: String!, account: GITAccount!, error: NSError!) {
    print("GIT finished sign in and returned token \(token) for account \(account) with error \(error)")
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(token, forKey: "customerToken")
    userDefaults.synchronize()
    performSegueWithIdentifier("signInCustomer", sender: token)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let destination = (segue.destinationViewController) as! CustomerViewController
    destination.idToken = sender as! String
  }
}