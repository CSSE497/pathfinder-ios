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

  var id: Int?
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

  convenience init(id: Int, description: String, location: CLLocationCoordinate2D, image: UIImage) {
    self.init(description: description, location: location, image: image)
    self.id = id
  }

  class func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
    UIGraphicsBeginImageContext(CGSizeMake(width, height))
    image.drawInRect(CGRectMake(0, 0, width, height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }

  func post() {
    print("About to post chimney with name \(description)")
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

  func delete() {
    print("About to delete chimney \(id)")
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: NSURL(string: Chimney.postUrl + "?id=\(id!)")!)
    request.HTTPMethod = "DELETE"
    var done = false
    let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      print("Received response from webserver: \(response) with data \(NSString(data: data!, encoding: NSASCIIStringEncoding))")
      done = true
    }
    task.resume()
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
    let id = jsonResponse["id"] as! Int
    let imageUrl = jsonResponse["image"] as! String
    let imageData = NSData(contentsOfURL: NSURL(string: imageUrl)!)
    return Chimney(id: id, description: description, location: CLLocationCoordinate2D(latitude: lat, longitude: lng), image: UIImage(data: imageData!)!)
  }
}