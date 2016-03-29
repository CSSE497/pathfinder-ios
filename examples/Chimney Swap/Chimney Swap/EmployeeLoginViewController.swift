//
//  EmployeeLoginViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class EmployeeLoginViewController : UIViewController {

  @IBAction func signInEmployee() {
    let interfaceManager = GITInterfaceManager()
    interfaceManager.delegate = self
    GITClient.sharedInstance().delegate = self
    interfaceManager.startSignIn()
  }
}

extension EmployeeLoginViewController : GITInterfaceManagerDelegate, GITClientDelegate {

  func client(client: GITClient!, didFinishSignInWithToken token: String!, account: GITAccount!, error: NSError!) {
    print("GIT finished sign in and returned token \(token) for account \(account) with error \(error)")
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(token, forKey: "employeeToken")
    userDefaults.synchronize()
    self.performSegueWithIdentifier("signInEmployee", sender: token)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let destination = (segue.destinationViewController) as! EmployeeViewController
    destination.idToken = sender as! String
  }
}