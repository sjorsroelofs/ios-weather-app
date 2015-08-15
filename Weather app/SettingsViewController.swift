//
//  SettingsViewController.swift
//  Weather app
//
//  Created by Sjors Roelofs on 15/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tempUnitSwitch: UISegmentedControl!;
    
    var defaultUserSettings: NSUserDefaults? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        defaultUserSettings = NSUserDefaults.standardUserDefaults();

        tempUnitSwitch.addTarget(self, action: "tempUnitDidChange", forControlEvents: .ValueChanged);
        tempUnitSwitch.selectedSegmentIndex = getPreferredTempUnitIndex();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tempUnitDidChange() {
        defaultUserSettings!.setInteger(tempUnitSwitch.selectedSegmentIndex, forKey: "tempUnitIndex");
    }
    
    // MARK: Getters
    func getPreferredTempUnitIndex() -> Int {
        return defaultUserSettings!.integerForKey("tempUnitIndex");
    }

}
