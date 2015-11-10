//
//  Chimney.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class Chimney {

  static let baseUrl = "http://chimneyswap.xyz/"
  static let postUrl = baseUrl + "chimney"

  let description: String
  let location: CLLocationCoordinate2D
  let image: UIImage

  let imageWidth: CGFloat = 480
  let imageHeight: CGFloat =  640

  init(description: String, location: CLLocationCoordinate2D, image: UIImage) {
    self.description = description
    self.location = location
    self.image = Chimney.resizeImage(image, width: imageWidth, height: imageHeight)
  }

  class func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
    UIGraphicsBeginImageContext(CGSizeMake(width, height))
    image.drawInRect(CGRectMake(0, 0, width, height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }

  func post() {
    let imageData = UIImageJPEGRepresentation(image, 0.9)
    let base64string = imageData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let data = [
      "position": [
        "lat": location.latitude,
        "lng": location.longitude
      ],
      "name": description,
      "image": [
        "content_type": "image/jpeg",
        "file_data": base64string!
      ]
    ]
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: NSURL(string: Chimney.postUrl)!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    var done = false
    do {
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
      let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        print("Received response from webserver: \(response) with data \(NSString(data: data!, encoding: NSASCIIStringEncoding))")
        done = true
      }
      task.resume()
    } catch {
      print("Received error from webserver: \(error)")
    }
    while (!done) { }
  }

  class func parse(jsonResponse: NSDictionary) -> Chimney? {
    print("Attempting to parse as Chimney: \(jsonResponse)")
    let description = jsonResponse["name"] as! String
    var lat: Double = 0
    var lng: Double = 0
    if let position = jsonResponse["position"] as? NSDictionary {
      lat = position["lat"] as! Double
      lng = position["lng"] as! Double
    }
    let imagePath = jsonResponse["image"] as! String
    let imageData = NSData(contentsOfURL: NSURL(string: baseUrl + imagePath)!)
    return Chimney(description: description, location: CLLocationCoordinate2D(latitude: lat, longitude: lng), image: UIImage(data: imageData!)!)
  }
}