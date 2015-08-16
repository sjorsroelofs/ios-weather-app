//
//  Forecast.swift
//  Weather app
//
//  Created by Sjors Roelofs on 10/08/15.
//  Copyright (c) 2015 Sjors Roelofs. All rights reserved.
//

import Foundation

class Forecast {
    private let endpoint = NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%3D729282&format=json");
    private var notificationCenter = NSNotificationCenter.defaultCenter();
    private let dateFormatter = NSDateFormatter();
    
    private var currentTemperatureFahrenheit: Int;
    private var lastUpdated: NSDate;
    private var forecastDays: Array<ForecastDay>;
    private var locationTitle: String;
    private var errorLoadingData = true;
    
    struct ForecastDay {
        var label: String;
        var date: NSDate;
        var tempLow: Int;
        var tempHigh: Int;
    }


    // MARK: Initializers
    init(currentTemperatureFahrenheit: Int) {
        self.currentTemperatureFahrenheit = currentTemperatureFahrenheit;
        self.lastUpdated = NSDate();
        self.forecastDays = [];
        self.locationTitle = "";
        
        loadData();
    }
    
    
    // MARK: Other methods
    private func loadData() -> Bool {
        let data = NSData(contentsOfURL: endpoint!);
        
        configureDateFormatter();
        
        if data != nil {
            if let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                if let channel = json.valueForKeyPath("query.results.channel") as? NSDictionary {
                    if let location = channel.valueForKeyPath("location") as? NSDictionary {
                        setLocationTitle(location["city"] as! String);
                    }
                    
                    if let condition = channel.valueForKeyPath("item.condition") as? NSDictionary {
                        self.currentTemperatureFahrenheit = Int((condition["temp"] as! String))!;
                    }
                    
                    if let forecast = channel.valueForKeyPath("item.forecast") as? NSArray {
                        if forecast.count >= 5 {
                            forecastDays.append(ForecastDay(
                                label: "tomorrow",
                                date: getDateFromString(forecast[1]["date"] as! String, withFormat: "d MMM yyyy"),
                                tempLow: Int((forecast[1]["low"] as! String))!,
                                tempHigh: Int((forecast[1]["high"] as! String))!)
                            )
                            
                            forecastDays.append(ForecastDay(
                                label: "tomorrow",
                                date: getDateFromString(forecast[2]["date"] as! String, withFormat: "d MMM yyyy"),
                                tempLow: Int((forecast[2]["low"] as! String))!,
                                tempHigh: Int((forecast[2]["high"] as! String))!)
                            )
                            
                            forecastDays.append(ForecastDay(
                                label: "tomorrow",
                                date: getDateFromString(forecast[3]["date"] as! String, withFormat: "d MMM yyyy"),
                                tempLow: Int((forecast[3]["low"] as! String))!,
                                tempHigh: Int((forecast[3]["high"] as! String))!)
                            )
                            
                            forecastDays.append(ForecastDay(
                                label: "tomorrow",
                                date: getDateFromString(forecast[4]["date"] as! String, withFormat: "d MMM yyyy"),
                                tempLow: Int((forecast[4]["low"] as! String))!,
                                tempHigh: Int((forecast[4]["high"] as! String))!)
                            )
                        }
                    }
                    
                    setLastUpdateDate(NSDate());
                    errorLoadingData = false;
                    notificationCenter.postNotification(NSNotification(name: "data updated", object: nil));
                    
                    return true;
                }
            }
        }
        
        errorLoadingData = true;
        notificationCenter.postNotification(NSNotification(name: "loading data failed", object: nil));
        
        return false;
    }
    
    func reload() {
        loadData();
    }

    private func configureDateFormatter() {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_GB");
        dateFormatter.dateFormat = "EEE, dd MMM yyyy h:mm a z";
    }
    
    func checkIfDataNeedsUpdate() {
        if NSDate().timeIntervalSinceDate(getLastUpdateDate()) > 60 * 5 {
            reload();
        }
    }
    
    
    // MARK: Setters
    private func setLocationTitle(title: String) {
        self.locationTitle = title;
    }
    
    private func setLastUpdateDate(date: NSDate) {
        lastUpdated = date;
    }
    
    
    // MARK: Getters
    func getCurrentTemperatureFahrenheit() -> Int {
        return currentTemperatureFahrenheit;
    }
    
    func getLocation() -> String {
        return locationTitle;
    }
    
    func getLastUpdateDate() -> NSDate {
        return lastUpdated;
    }
    
    func getForecast() -> Array<ForecastDay> {
        return forecastDays;
    }
    
    private func getDateFromString(string: String, withFormat: String) -> NSDate {
        dateFormatter.dateFormat = withFormat;
        
        if let date = dateFormatter.dateFromString(string) {
            return date;
        } else {
            return NSDate();
        }
    }
    
    func isDataSuccessfullyLoaded() -> Bool {
        return !errorLoadingData;
    }
    
}