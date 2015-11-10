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
  @IBOutlet weak var footer: UIButton!

  static let chimneysEndpoint = Chimney.baseUrl + "chimneys"

  var chimneys = [Chimney]()
  var refreshControl: UIRefreshControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    refreshControl = UIRefreshControl()
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh chimneys")
    refreshControl.backgroundColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: "fetchChimneys", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    fetchChimneys()
  }

  func fetchChimneys() {
    chimneys = [Chimney]()
    let url = NSURL(string: CustomerViewController.chimneysEndpoint)!
    let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      if error != nil {
        print("SHIT! Received error from server: \(error)")
      }
      do {
        let jsonResults: NSArray = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
        jsonResults.forEach { (jsonDict: AnyObject) -> Void in
          if let chimney: Chimney = Chimney.parse(jsonDict as! NSDictionary) {
            self.chimneys.append(chimney)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
              self.tableView.reloadData()
            }
          }
        }
      } catch {
        print("Failed to retrieve chimneys: \(error)")
      }
      self.refreshControl.endRefreshing()
    }
    task.resume()
  }
}

extension CustomerViewController : UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("User selected row at index path \(indexPath)")
    let vc = storyboard?.instantiateViewControllerWithIdentifier("AcceptSwapViewController") as? AcceptSwapViewController
    vc?.tradeDescription = chimneys[indexPath.row].description
    vc?.tradeImage = chimneys[indexPath.row].image
    vc?.tradeLocation = chimneys[indexPath.row].location
    navigationController?.pushViewController(vc!, animated: true)
  }
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
    let location = chimneys[indexPath.row].location
    cell.detailTextLabel?.text = "\(location.latitude) \(location.longitude)"
    return cell
  }
}