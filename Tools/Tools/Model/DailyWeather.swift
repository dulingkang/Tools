//
//  DailyWeather.swift
//  Tools
//
//  Created by ShawnDu on 15/9/12.
//  Copyright (c) 2015年 dulingkang. All rights reserved.
//

import Foundation

struct DailyWeather {
    var minTemperature: String
    var maxTemperature: String

    init (weatherDict: NSDictionary) {
        let dailyArray = weatherDict["daily_forecast"] as! NSArray
        let dailyDict = dailyArray[0] as! NSDictionary
        let temperatureDict = dailyDict["tmp"] as! NSDictionary
        minTemperature = temperatureDict["min"] as! String
        maxTemperature = temperatureDict["max"] as! String
    }
}