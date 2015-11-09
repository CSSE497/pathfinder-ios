//
//  SwapChimneyViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class SwapChimneyViewController : UIViewController {

  @IBOutlet weak var descriptionText: UITextField!

  @IBOutlet weak var imageView: UIImageView!

  let imagePicker = UIImagePickerController()
  let locationManager = CLLocationManager()

  var location: CLLocationCoordinate2D?

  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    self.locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }

  @IBAction func imageChooser() {
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .PhotoLibrary
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func addChimney() {
    let description = descriptionText.text!
    let image = imageView.image!
    let lat = location!.latitude
    let lng = location!.longitude
    Chimney(description: description, location: CLLocationCoordinate2D(latitude: lat, longitude: lng), image: image).post()
    dismissViewControllerAnimated(true, completion: nil)
  }

}

extension SwapChimneyViewController : UIImagePickerControllerDelegate {

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.contentMode = .ScaleAspectFit
      imageView.image = pickedImage
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension SwapChimneyViewController : UINavigationControllerDelegate {

}

extension SwapChimneyViewController : CLLocationManagerDelegate {

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("SwapChimneyViewController received location authorization status: \(status)")
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("SwapChimneyViewController received location updated: \(locations)")
    location = locations[0].coordinate
  }
}