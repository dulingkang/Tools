//
//  MainViewController.swift
//  Tools
//
//  Created by ShawnDu on 15/9/7.
//  Copyright (c) 2015年 dulingkang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class MainViewController: UITableViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var locationString: UILabel!
    @IBOutlet weak var sunSmallImage: UIImageView!
    @IBOutlet weak var sunLabelString: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var pmValue: UILabel!
    @IBOutlet weak var pmString: UILabel!
    
//    let swipeRec = UISwipeGestureRecognizer()
    var audioPlayer = AVAudioPlayer()
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var locationManager: CLLocationManager!
    var userLocation : String!
    var userLatitude : Double!
    var userLongitude : Double!
    //MARK: lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: Selector("pullRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: tableView delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    
//    }
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: private method
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    func refresh() {
        initLocationManager()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            let pm = placemarks[0] as! CLPlacemark
            self.displayLocationInfo(pm)
        })
        
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as! CLLocation
            var coord = locationObj.coordinate
            self.userLatitude = coord.latitude
            self.userLongitude = coord.longitude
            
            getCurrentWeatherData()
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            println(locality)
            println(postalCode)
            println(administrativeArea)
            println(country)
            
            //            self.userLocationLabel.text = "\(locality), \(administrativeArea)"
        }
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            case CLAuthorizationStatus.AuthorizedWhenInUse:
                locationStatus = "authorizedInuse"
                shouldIAllow = true
            case CLAuthorizationStatus.AuthorizedAlways:
                locationStatus = "always"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }
    
    func getCurrentWeatherData() -> Void {
        userLocation = "\(userLatitude),\(userLongitude)"
        var url = "http://apis.baidu.com/heweather/weather/free"
        var httpArg = "city=beijing"
        var req = NSMutableURLRequest(URL: NSURL(string:url + "?" + httpArg)!)
        req.timeoutInterval = 6
        req.HTTPMethod = "GET"
        req.addValue("49d3115af12dfd8be95b0f29f970c3ca", forHTTPHeaderField: "apikey")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            if error == nil{
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
                let weatherArray : NSArray = weatherDictionary["HeWeather data service 3.0"] as! NSArray
                let weatherDict : NSDictionary = weatherArray[0] as! NSDictionary
                let currentWeather = CurrentWeather(weatherDict: weatherDict)
                let dailyWeather = DailyWeather(weatherDict: weatherDict)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentTemperature.text = currentWeather.currentTemperature
                    self.pmValue.text = currentWeather.pmValue
                    self.pmString.text = currentWeather.pmString
                    self.sunLabelString.text = currentWeather.sunLabelString
                    self.minTemperature.text = dailyWeather.minTemperature
                    self.maxTemperature.text = dailyWeather.maxTemperature
                })
                println(weatherDictionary)
            }
        })
        task.resume()
    }
    
    func request(httpUrl: String, httpArg: String) {
        var req = NSMutableURLRequest(URL: NSURL(string: httpUrl + "?" + httpArg)!)
        req.timeoutInterval = 6
        req.HTTPMethod = "GET"
        req.addValue("49d3115af12dfd8be95b0f29f970c3ca", forHTTPHeaderField: "apikey")
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) -> Void in
            let res = response as! NSHTTPURLResponse
            println(res.statusCode)
            if let e = error{
                println("请求失败")
            }
            if let d = data {
                var content = NSString(data: d, encoding: NSUTF8StringEncoding)
                println(content)
            }
        }
    }
    
    func swooshsound() {
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("swoosh", ofType: "wav")!)
        println(alertSound)
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func pullRefresh(sender:AnyObject) {
        self.swooshsound()
        refresh()
    }
}