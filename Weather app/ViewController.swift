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
        
        notificationCenter.addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil);

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload..");
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl);
        
        self.locations.append(Forecast());
    }

    override func viewWillAppear(animated: Bool) {
        for cell in cells {
            cell.hideViews();
        }
    }

    override func viewDidAppear(animated: Bool) {
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
        refreshControl.endRefreshing();
        
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

