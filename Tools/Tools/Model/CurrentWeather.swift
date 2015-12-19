//
//  CurrentWeather.swift
//  Tools
//
//  Created by ShawnDu on 15/9/12.
//  Copyright (c) 2015年 dulingkang. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {
    var sunLabelString: String
    var currentTemperature: String
    var pmValue: String
    var pmString: String
    
    init (weatherDict: NSDictionary) {
        let nowWeatherDict = weatherDict["now"] as! NSDictionary
        currentTemperature = nowWeatherDict["tmp"] as! String
        let condSunDict = nowWeatherDict["cond"] as! NSDictionary
        sunLabelString = condSunDict["txt"] as! String
        let aqiDict = weatherDict["aqi"] as! NSDictionary
        let cityDict = aqiDict["city"] as! NSDictionary
        pmValue = cityDict["pm25"] as! String
        pmString = cityDict["qlty"] as! String
    }
}