//
//  ViewController.swift
//  SampleApp
//
//  Created by Adam Michael on 10/4/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, WebSocketDelegate {
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var mapTasks = MapTasks()
    var commodities: Array<GMSMarker> = []
    var vehicles: Array<GMSMarker> = []
    var addingState: Adding = .Nothing
    var commodityColor: UIColor = ViewController.randColor()
    var socket: WebSocket? = WebSocket(url: NSURL(string: "ws://192.168.2.162:9000/socket")!)
    var socketConnected = false
    var startCommodityLocation: CLLocationCoordinate2D!
    var routes = Dictionary<Int, GMSPolyline>()
    
    enum Adding {
        case FirstCommodity
        case SecondCommodity
        case Vehicle
        case Nothing
    }

    @IBOutlet weak var viewMap: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.cameraWithLatitude(41.0, longitude: 41.0, zoom: 8.0)
        viewMap.camera = camera;
        viewMap.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        self.socket?.delegate = self
        self.socket?.connect()
    }

    @IBAction func newSocket(sender: AnyObject) {
        let ipAlert = UIAlertController(title: "Server IP", message: "Type the IP of the Pathfinder server", preferredStyle: UIAlertControllerStyle.Alert)
        ipAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address?"
        }
        let ipAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.Default) { (action) -> Void in
            let ip: String = (ipAlert.textFields![0] as UITextField).text!
            self.socket = WebSocket(url: NSURL(string: "ws://\((ipAlert.textFields![0] as UITextField).text!):9000/socket")!)
            self.socket?.delegate = self
            self.socket?.connect()
            self.socketConnected = false
        }
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (action) -> Void in }
        ipAlert.addAction(ipAction)
        ipAlert.addAction(closeAction)
        presentViewController(ipAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func newCommodity(sender: AnyObject) {
        addingState = .FirstCommodity
    }
    
    @IBAction func newVehicle(sender: AnyObject) {
        addingState = .Vehicle
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as!
            CLLocation
            viewMap.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            viewMap.settings.myLocationButton = true
            didFindMyLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            viewMap.myLocationEnabled = true
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        switch addingState {
        case .FirstCommodity:
            let marker = GMSMarker(position: coordinate)
            marker.map = viewMap
            marker.title = "Start"
            marker.appearAnimation = kGMSMarkerAnimationPop
            commodityColor = ViewController.randColor()
            marker.icon = GMSMarker.markerImageWithColor(commodityColor)
            addingState = .SecondCommodity
            startCommodityLocation = coordinate
            return
        case .SecondCommodity:
            let marker = GMSMarker(position: coordinate)
            marker.map = viewMap
            marker.title = "End"
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.icon = GMSMarker.markerImageWithColor(commodityColor)
            addingState = .Nothing
            writeCommodityFrom(startCommodityLocation, to: coordinate)
            return
        case .Vehicle:
            let marker = GMSMarker(position: coordinate)
            marker.map = viewMap
            marker.title = "Vehicle"
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.icon = UIImage(named: "mario.gif")
            addingState = .Nothing
            writeVehicle(coordinate)
            return
        case .Nothing:
            return
        }
    }
    
    // Sends a socket create vehicle message to Pathfinder.
    func writeVehicle(coordinate: CLLocationCoordinate2D) {
        let data = [
            "create": [
                "model": "Vehicle",
                "value": [
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude,
                    "capacity": 2
                ]
            ]
        ]
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: json, encoding: NSUTF8StringEncoding)
            socket?.writeString(jsonString! as String)
        } catch {
            print(error)
        }
    }
    
    // Sends a socket create commodity message to Pathfinder.
    func writeCommodityFrom(start: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        let data = [
            "create": [
                "model": "Commodity",
                "value": [
                    "startLatitude": start.latitude,
                    "startLongitude": start.longitude,
                    "endLatitude": to.latitude,
                    "endLongitude": to.longitude,
                    "param": 1
                ]
            ]
        ]
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: json, encoding: NSUTF8StringEncoding)
            socket?.writeString(jsonString! as String)
        } catch {
            print(error)
        }
    }
    
    // Sends a socket route request message for a vehicle to Pathfinder.
    func readRoute(vehicleId: Int) {
        let data = [ "route": [ "model": "Vehicle", "id": vehicleId ] ]
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: json, encoding: NSUTF8StringEncoding)
            socket?.writeString(jsonString! as String)
        } catch {
            print(error)
        }
    }
    
    class func randColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(socket: WebSocket) {
        socketConnected = true
        print("Socket is now connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        socketConnected = false
        print("Socket is now disconnected")
        print(error)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    }
    
    // Receives socket messages from Pathfinder.
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("I got a message: \(text)")
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers)
            if let message: NSDictionary = json as? NSDictionary {
                if let created = message["created"] as? NSDictionary {
                    if created["model"] as? String == "Vehicle" {
                        if let vehicle = created["value"] as? NSDictionary {
                            let vehicleId = vehicle["id"] as! Int
                            print("Requesting route for \(vehicleId)")
                            readRoute(vehicleId)
                        }
                    }
                } else if let routed: NSDictionary = message["routed"] as? NSDictionary {
                    var path: [CLLocationCoordinate2D] = []
                    var vehicleId = 0
                    if routed["model"] as? String == "Vehicle" {
                        if let route = routed["value"] as? NSDictionary {
                            if let actions = route["actions"] as? NSArray {
                                for actionEntry in actions {
                                    if let action = actionEntry as? NSDictionary {
                                        let lat = action["latitude"] as! Double
                                        let lng = action["longitude"] as! Double
                                        path.append(CLLocationCoordinate2D.init(latitude: lat, longitude: lng))
                                    }
                                }
                            }
                            vehicleId = route["vehicle"] as! Int
                        }
                    }
                    mapTasks.getDirections(path, vehicleId: vehicleId, completionHandler: drawRoute)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func drawRoute(vehicleId: Int, encodedPath: String) {
        print("Drawing route for vehicle \(vehicleId)")
        let path = GMSPath(fromEncodedPath: encodedPath)
        if routes[vehicleId] != nil {
            routes[vehicleId]?.map = nil
        }
        routes[vehicleId] = GMSPolyline(path: path)
        routes[vehicleId]?.map = viewMap
        routes[vehicleId]?.strokeColor = ViewController.randColor()
        routes[vehicleId]?.strokeWidth = 5
    }
}

