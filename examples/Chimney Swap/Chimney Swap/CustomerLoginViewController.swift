//
//  CustomerLoginViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class CustomerLoginViewController : UIViewController {

  var signIn: GIDSignIn!

  let interfaceManager = GITInterfaceManager()

  override func viewDidLoad() {
    interfaceManager.delegate = self
    GITClient.sharedInstance().delegate = self
  }

  @IBAction func signInCustomer() {
//    signIn.signIn()
    interfaceManager.startSignIn()
  }
}

// MARK: - GITClientDelegate
extension CustomerLoginViewController: GITInterfaceManagerDelegate, GITClientDelegate {

  func client(client: GITClient!, didFinishSignInWithToken token: String!, account: GITAccount!, error: NSError!) {
    print("GIT finished sign in and returned token \(token) for account \(account) with error \(error)")
    self.performSegueWithIdentifier("signIn", sender: self)
  }
}