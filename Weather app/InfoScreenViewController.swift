//
//  InfoScreenViewController.swift
//  Weather app
//
//  Created by Sjors Roelofs on 13/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit

class InfoScreenViewController: UIViewController {

    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func didSwiped(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true);
    }

}
