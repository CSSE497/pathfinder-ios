//
//  CompleteSwapViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/9/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import thepathfinder

class AcceptSwapViewController : UIViewController {
  @IBOutlet weak var descriptionText: UITextField!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var tradeImageView: UIImageView!
  @IBOutlet weak var swapButton: UIButton!

  let imagePicker = UIImagePickerController()
  let locationManager = CLLocationManager()
  var location: CLLocationCoordinate2D?
  var tradeChimney: Chimney?
  let path = "/root/midwest/th"

  override func viewDidLoad() {
    super.viewDidLoad()
    tradeImageView.image = tradeChimney!.image
    imagePicker.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    swapButton.enabled = false

    descriptionText.delegate = self
  }

  @IBAction func imageChooser() {
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .PhotoLibrary
    presentViewController(imagePicker, animated: true, completion: nil)
  }

  @IBAction func performSwap() {
    tradeChimney?.delete()

    let cluster = Pathfinder(applicationIdentifier: Constants.Pathfinder.applicationId, userCredentials: "").cluster(path)

    // Current user's old chimney
    cluster.createCommodity(location!, destination: tradeChimney!.location, metadata: ["chimney": 1]).request()

    // Current user's new chimney
    cluster.createCommodity(tradeChimney!.location, destination: location!, metadata: ["chimney": 1]).request()

    navigationController?.popViewControllerAnimated(true)
  }
}

extension AcceptSwapViewController : UITextFieldDelegate {
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    descriptionText.endEditing(true)
  }
}

extension AcceptSwapViewController : UINavigationControllerDelegate { }

extension AcceptSwapViewController : UIImagePickerControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.contentMode = .ScaleAspectFill
      imageView.image = pickedImage
    }
    dismissViewControllerAnimated(true, completion: nil)
    swapButton.enabled = true
  }
}

extension AcceptSwapViewController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("AcceptSwapViewController received location authorization status: \(status)")
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    location = locations[0].coordinate
  }
}