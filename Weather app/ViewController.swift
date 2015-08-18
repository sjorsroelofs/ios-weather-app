//
//  ViewController.swift
//  Weather app
//
//  Created by Sjors Roelofs on 05/08/15.
//  Copyright (c) 2015 Sjors Roelofs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Properties
    let notificationCenter = NSNotificationCenter.defaultCenter();
    let refreshControl = UIRefreshControl();
    var locations = [Forecast]();
    var cells = [LocationForecastTableViewCell]();

    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.addSubview(refreshControl);
        tableView.sendSubviewToBack(refreshControl);
        
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload..", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]);
        refreshControl.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        
        notificationCenter.addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil);
        
        self.locations.append(Forecast());
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }

    override func viewWillAppear(animated: Bool) {
        for cell in cells {
            cell.hideViews();
        }
    }

    override func viewDidAppear(animated: Bool) {
        refreshControl.endRefreshing();
        
        for cell in cells {
            cell.updateView();
        }
    }
    
    func didBecomeActive(notification: NSNotification) {
        for cell in cells {
            cell.checkIfDataNeedsUpdate();
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "endRefresh", userInfo: nil, repeats: false);
        reloadCells();
    }
    
    func endRefresh() {
        refreshControl.endRefreshing();
    }
    
    func reloadCells() {
        for cell in cells {
            cell.reload();
        }
    }


    // MARK: UITableViewDataSource method implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationForecastTableViewCell;
        
        cells.append(cell);
        cell.setForecast(locations[indexPath.row]);
        
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.height;
    }

}

