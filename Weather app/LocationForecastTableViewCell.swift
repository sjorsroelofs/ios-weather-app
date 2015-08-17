//
//  LocationForecastTableViewCell.swift
//  Weather app
//
//  Created by Sjors Roelofs on 16/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit

class LocationForecastTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var atThisMoment: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var measuredDateTime: UILabel!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var errorMessage: UILabel!
    
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

    
    // MARK: Properties
    let notificationCenter = NSNotificationCenter.defaultCenter();
    var defaultUserSettings: NSUserDefaults? = nil;
    let dateFormatter = NSDateFormatter();
    var forecast: Forecast? = nil;
    
    var temperatureAnimateTimer: NSTimer?;
    var temperatureAnimateCounter = 0;
    
    
    // MARK: Methods
    override func awakeFromNib() {
        super.awakeFromNib();
        
        defaultUserSettings = NSUserDefaults.standardUserDefaults();
        
        notificationCenter.addObserver(self, selector: "dataChanged:", name: "data updated", object: forecast);
    }
    
    
    // MARK: Actions
    func reload() {
        self.showLoadingIcon();
        self.fadeViewsOut({ () -> Void in
            self.forecast!.reload();
        });
    }
    
    func checkIfDataNeedsUpdate() {
        if forecast != nil {
            forecast!.checkIfDataNeedsUpdate();
        }
    }

    
    // MARK: Event listeners
    func dataChanged(notification: NSNotification) {
        if forecast != nil {
            updateView();
        }
    }
    
    func errorLoadingData() {
        hideLoadingIcon();
        showErrorMessage()
    }
    
    
    // MARK: Setters
    func setForecast(forecast: Forecast) {
        self.forecast = forecast;
    }
    
    
    // MARK: Getters
    func getPreferredTempUnitIndex() -> Int {
        return defaultUserSettings!.integerForKey("tempUnitIndex");
    }
    
    func fahrenheitToCelsius(fahrenheit: Int) -> Int {
        return Int(round(((Double(fahrenheit) - 32) * 5) / 9));
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
    
    func getWeekdayForDate(date: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!;
        let components = calendar.components(.Weekday, fromDate: date);
        var weekday = components.weekday - 1;
        
        if weekday == 0 {
            weekday = 7;
        }
        
        return weekday;
    }
    
    func getTemperatureInPreferedUnit(temperatureFahrenheit: Int) -> Int {
        if getPreferredTempUnitIndex() == 0 {
            return fahrenheitToCelsius(temperatureFahrenheit);
        } else {
            return temperatureFahrenheit;
        }
    }

    
    // MARK: User interface setters
    func updateView() {
        hideErrorMessage();
        showLoadingIcon();
        
        fadeViewsOut({ () -> Void in
            if self.forecast!.isDataSuccessfullyLoaded() {
                self.setCurrentLocationTitle();
                self.setTemperature();
                self.setForecast();
                self.setLastUpdatedTime();
                
                self.fadeViewsIn();
                self.hideLoadingIcon();
            }
        });
        
        if !forecast!.isDataSuccessfullyLoaded() {
            errorLoadingData();
        }
    }
    
    func setCurrentLocationTitle() {
        atThisMoment.text = "at this moment in " + forecast!.getLocation().lowercaseString;
    }
    
    func setTemperature() {
        temperatureAnimateCounter = 0;
        currentTemperature.text = "0˚";
        
        if temperatureAnimateTimer != nil {
            temperatureAnimateTimer!.invalidate();
            temperatureAnimateTimer = nil;
        }
        
        for index in 0...getTemperatureInPreferedUnit(forecast!.getCurrentTemperatureFahrenheit()) {
            temperatureAnimateTimer = NSTimer.scheduledTimerWithTimeInterval(Double(index) * 0.06, target: self, selector: "incrementTemperature", userInfo: nil, repeats: false);
        }
    }
    
    func incrementTemperature() {
        if temperatureAnimateCounter <= getTemperatureInPreferedUnit(forecast!.getCurrentTemperatureFahrenheit()) {
            self.currentTemperature.text = String(temperatureAnimateCounter++) + "˚";
        }
    }
    
    func setForecast() {
        var forecastDays = forecast!.getForecast();
        
        forecastDay1Label.hidden = true;
        forecastDay1ValueMax.hidden = true;
        forecastDay1ValueMin.hidden = true;
        forecastDay2Label.hidden = true;
        forecastDay2ValueMax.hidden = true;
        forecastDay2ValueMin.hidden = true;
        forecastDay3Label.hidden = true;
        forecastDay3ValueMax.hidden = true;
        forecastDay3ValueMin.hidden = true;
        forecastDay4Label.hidden = true;
        forecastDay4ValueMax.hidden = true;
        forecastDay4ValueMin.hidden = true;
        
        if forecastDays.count >= 1 {
            forecastDay1Label.text = "tomorrow";
            forecastDay1ValueMax.text = String(getTemperatureInPreferedUnit(forecastDays[0].tempHigh)) + "˚";
            forecastDay1ValueMin.text = String(getTemperatureInPreferedUnit(forecastDays[0].tempLow)) + "˚";
            
            forecastDay1Label.hidden = false;
            forecastDay1ValueMax.hidden = false;
            forecastDay1ValueMin.hidden = false;
        }
        
        if forecastDays.count >= 2 {
            forecastDay2Label.text = getDayOfWeekFromDayOfWeekNumber(getWeekdayForDate(forecastDays[1].date)).lowercaseString;
            forecastDay2ValueMax.text = String(getTemperatureInPreferedUnit(forecastDays[1].tempHigh)) + "˚";
            forecastDay2ValueMin.text = String(getTemperatureInPreferedUnit(forecastDays[1].tempLow)) + "˚";
            
            forecastDay2Label.hidden = false;
            forecastDay2ValueMax.hidden = false;
            forecastDay2ValueMin.hidden = false;
        }
        
        if forecastDays.count >= 3 {
            forecastDay3Label.text = getDayOfWeekFromDayOfWeekNumber(getWeekdayForDate(forecastDays[2].date)).lowercaseString;
            forecastDay3ValueMax.text = String(getTemperatureInPreferedUnit(forecastDays[2].tempHigh)) + "˚";
            forecastDay3ValueMin.text = String(getTemperatureInPreferedUnit(forecastDays[2].tempLow)) + "˚";
            
            forecastDay3Label.hidden = false;
            forecastDay3ValueMax.hidden = false;
            forecastDay3ValueMin.hidden = false;
        }
        
        if forecastDays.count >= 4 {
            forecastDay4Label.text = getDayOfWeekFromDayOfWeekNumber(getWeekdayForDate(forecastDays[3].date)).lowercaseString;
            forecastDay4ValueMax.text = String(getTemperatureInPreferedUnit(forecastDays[3].tempHigh)) + "˚";
            forecastDay4ValueMin.text = String(getTemperatureInPreferedUnit(forecastDays[3].tempLow)) + "˚";
            
            forecastDay4Label.hidden = false;
            forecastDay4ValueMax.hidden = false;
            forecastDay4ValueMin.hidden = false;
        }
    }
    
    func setLastUpdatedTime() {
        dateFormatter.dateFormat = "d MMMM 'at' H:mm";
        measuredDateTime.text = "last update: " + dateFormatter.stringFromDate(forecast!.getLastUpdateDate()).lowercaseString;
    }
    
    
    // MARK: User interface animations
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
        measuredDateTime.alpha = 0.0;
    }
    
    func fadeViewsOut(callback: (() -> Void)?) {
        UIView.animateWithDuration(0.2, animations: {
            self.atThisMoment.alpha = 0.0;
            self.currentTemperature.alpha = 0.0;
            self.forecastContainer.alpha = 0.0;
            self.measuredDateTime.alpha = 0.0;
        }) { (completed: Bool) -> Void in
                if completed == true && callback != nil {
                    callback!();
                }
        };
    }
    
    func showLoadingIcon() {
        if self.loadingIcon.hidden == true {
            self.loadingIcon.alpha = 0.0;
            self.loadingIcon.hidden = false;
            
            UIView.animateWithDuration(0.5, animations: {
                self.loadingIcon.alpha = 1.0;
            });
        }
    }
    
    func hideLoadingIcon() {
        if self.loadingIcon.hidden == false {
            self.loadingIcon.alpha = 1.0;
            self.loadingIcon.hidden = true;
            
            UIView.animateWithDuration(0.5, animations: {
                self.loadingIcon.alpha = 0.0;
            });
        }
    }
    
    func showErrorMessage() {
        errorMessage.hidden = false;
    }
    
    func hideErrorMessage() {
        errorMessage.hidden = true;
    }

}
