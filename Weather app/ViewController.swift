//
//  ViewController.swift
//  Weather app
//
//  Created by Sjors Roelofs on 05/08/15.
//  Copyright (c) 2015 Sjors Roelofs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var atThisMoment: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var measuredDateTime: UILabel!
    
    @IBOutlet weak var forecastContainer: UIView!
    @IBOutlet weak var forecastDay1Label: UILabel!
    @IBOutlet weak var forecastDay2Label: UILabel!
    @IBOutlet weak var forecastDay3Label: UILabel!
    @IBOutlet weak var forecastDay4Label: UILabel!
    @IBOutlet weak var forecastDay1ValueMax: UILabel!
    @IBOutlet weak var forecastDay1ValueMin: UILabel!
    @IBOutlet weak var forecastDay2ValueMax: UILabel!
    @IBOutlet weak var forecastDay2ValueMin: UILabel!
    @IBOutlet weak var forecastDay3ValueMax: UILabel!
    @IBOutlet weak var forecastDay3ValueMin: UILabel!
    @IBOutlet weak var forecastDay4ValueMax: UILabel!
    @IBOutlet weak var forecastDay4ValueMin: UILabel!
    
    let dateFormatter = NSDateFormatter();
    var lastUpdated = "";

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData();
        hideViews();
    }
    
    override func viewDidAppear(animated: Bool) {
        fadeViewsIn();
    }
    
    @IBAction func reload() {
        fadeViewsOut();
        loadData();
        fadeViewsIn();
    }
    
    func fadeViewsIn() {
        UIView.animateWithDuration(1.5, animations: {
            self.atThisMoment.alpha = 1.0;
            self.currentTemperature.alpha = 1.0;
            self.forecastContainer.alpha = 1.0;
            self.measuredDateTime.alpha = 1.0
        });
    }
    
    func hideViews() {
        atThisMoment.alpha = 0.0;
        currentTemperature.alpha = 0.0;
        forecastContainer.alpha = 0.0;
        measuredDateTime.alpha = 0.0
    }
    
    func fadeViewsOut() {
        UIView.animateWithDuration(0.2, animations: {
            self.atThisMoment.alpha = 0.0;
            self.currentTemperature.alpha = 0.0;
            self.forecastContainer.alpha = 0.0;
            self.measuredDateTime.alpha = 0.0
        });
    }
    
    func loadData() {
        let endpoint = NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%3D729282&format=json");
        let data = NSData(contentsOfURL: endpoint!);
        
        configureDateFormatter();
        
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            if let channel = json.valueForKeyPath("query.results.channel") as? NSDictionary {
                if let location = channel.valueForKeyPath("location") as? NSDictionary {
                    setCurrentLocationTitle(location["city"] as! String);
                }
                
                if let condition = channel.valueForKeyPath("item.condition") as? NSDictionary {
                    setCondition(String(fahrenheitToCelsius((condition["temp"] as! String).toInt()!)) + "˚");
                }
                
                if let forecast = channel.valueForKeyPath("item.forecast") as? NSArray {
                    if forecast.count >= 5 {
                        forecastDay1Label.text = "tomorrow";
                        forecastDay1ValueMax.text = String(fahrenheitToCelsius((forecast[1]["high"] as! String).toInt()!)) + "˚";
                        forecastDay1ValueMin.text = String(fahrenheitToCelsius((forecast[1]["low"] as! String).toInt()!)) + "˚";
                        
                        forecastDay2Label.text = getDayOfWeekFromDayOfWeekNumber(getWeekdayForDate(getDateFromString(forecast[2]["date"] as! String, withFormat: "d MMM yyyy")!)!).lowercaseString;
                        forecastDay2ValueMax.text = String(fahrenheitToCelsius((forecast[2]["high"] as! String).toInt()!)) + "˚";
                        forecastDay2ValueMin.text = String(fahrenheitToCelsius((forecast[2]["low"] as! String).toInt()!)) + "˚";
                        
                        forecastDay3Label.text = getDayOfWeekFromDayOfWeekNumber(getWeekdayForDate(getDateFromString(forecast[3]["date"] as! String, withFormat: "d MMM yyyy")!)!).lowercaseString;
                        forecastDay3ValueMax.text = String(fahrenheitToCelsius((forecast[3]["high"] as! String).toInt()!)) + "˚";
                        forecastDay3ValueMin.text = String(fahrenheitToCelsius((forecast[3]["low"] as! String).toInt()!)) + "˚";
                        
                        forecastDay4Label.text = getDayOfWeekFromDayOfWeekNumber(getWeekdayForDate(getDateFromString(forecast[4]["date"] as! String, withFormat: "d MMM yyyy")!)!).lowercaseString;
                        forecastDay4ValueMax.text = String(fahrenheitToCelsius((forecast[4]["high"] as! String).toInt()!)) + "˚";
                        forecastDay4ValueMin.text = String(fahrenheitToCelsius((forecast[4]["low"] as! String).toInt()!)) + "˚";
                    }
                }
                
                setLastUpdateDate(NSDate());
            }
            else {
                println("error parsing JSON: 'query.results.channel.item.condition' not found");
            }
        } else {
            println("error getting JSON");
        }
    }
    
    func fahrenheitToCelsius(fahrenheit: Int) -> Int {
        let fahrenheit: Double = Double(fahrenheit);
        let result: Double = round(((fahrenheit - 32) * 5) / 9);
        
        return Int(result);
    }
    
    func getDayOfWeekFromDayOfWeekNumber(number: Int) -> String {
        switch(number) {
            case 1: return "Monday";
            case 2: return "Tuesday";
            case 3: return "Wednesday";
            case 4: return "Thursday";
            case 5: return "Friday";
            case 6: return "Saturday";
            case 7: return "Sunday";
            default: return "Invalid day of week";
        }
    }
    
    func getDateFromString(string: String, withFormat: String) -> NSDate? {
        dateFormatter.dateFormat = withFormat;
        return dateFormatter.dateFromString(string);
    }
    
    func getWeekdayForDate(date: NSDate) -> Int? {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!;
        let components = calendar.components(.CalendarUnitWeekday, fromDate: date);
        
        return components.weekday - 1;
    }
    
    func configureDateFormatter() {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_GB");
        dateFormatter.dateFormat = "EEE, dd MMM yyyy h:mm a z";
    }
    
    func setLastUpdateDate(date: NSDate) {
        dateFormatter.dateFormat = "d MMMM 'at' H:mm";
        measuredDateTime.text = "last update: " + dateFormatter.stringFromDate(date).lowercaseString;
    }
    
    func setCurrentLocationTitle(location: String) {
        atThisMoment.text = "at this moment in " + location.lowercaseString;
    }
    
    func setCondition(condition: String) {
        self.currentTemperature.text = condition;
    }

}

