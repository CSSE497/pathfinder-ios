//
//  CustomerViewController.swift
//  Chimney Swap
//
//  Created by Adam Michael on 11/8/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class CustomerViewController : UIViewController {

  @IBOutlet weak var tableView: UITableView!

  static let chimneysEndpoint = Chimney.baseUrl + "/chimneys"

  var chimneys = [Chimney]()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    chimneys = fetchChimnneys()!
  }

  func fetchChimnneys() -> [Chimney]? {
    let url = NSURL(string: CustomerViewController.chimneysEndpoint)!
    var chimneys: [Chimney]? = nil
    var complete = false
    let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      do {
        let jsonResults: NSArray = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
        chimneys = jsonResults.map { (jsonDict: AnyObject) -> Chimney in
          return Chimney.parse(jsonDict as! NSDictionary)!
        }
      } catch {
        print("Failed to retrieve chimneys: \(error)")
      }
      complete = true
    }
    task.resume()
    while (!complete) { }
    return chimneys
  }
}

extension CustomerViewController : UITableViewDelegate {

}


extension CustomerViewController : UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("TableView requested number of rows in section \(section)")
    return chimneys.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    print("TableView requested cell for row at index path \(indexPath)")
    let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
    cell.textLabel!.text = chimneys[indexPath.row].description
    cell.imageView!.contentMode = .ScaleAspectFill
    cell.imageView!.frame = CGRectMake(0, 0, 40, 40)
    cell.imageView!.image = chimneys[indexPath.row].image
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("User selected row at index path \(indexPath)")
  }
}