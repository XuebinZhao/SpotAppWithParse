//
//  CounterViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController {
    
    ///UI Controls
    var timeLabel: UILabel?         // Show remaining time
    var startStopButton: UIButton?  // Start/Stop button
    var clearButton: UIButton?      // Reset button
    var timeButtons: [UIButton]?    // Buttons for setting time values
    let timeButtonInfos = [("10Min", 600), ("15Min", 900), ("30Min", 1800), ("1hour", 3600)]
    
    var remainingSeconds: Int = 0 {
        willSet(newSeconds) {
            
            let mins    = (newSeconds / 60) % 60
            let seconds = newSeconds % 60
            let hours   = newSeconds / (60 * 60)
            
            timeLabel!.text = NSString(format: "%02d:%02d:%02d", hours, mins, seconds) as String
            
            if newSeconds <= 0 {
                isCounting = false
                self.startStopButton!.alpha = 0.3
                self.startStopButton!.enabled = false
            } else {
                self.startStopButton!.alpha = 1.0
                self.startStopButton!.enabled = true
            }
            
        }
    }
    
    var timer: NSTimer?
    var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
                timer = nil
            }
            setSettingButtonsEnabled(!newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        setupTimeLabel()
        setuptimeButtons()
        setupActionButtons()
        
        remainingSeconds = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        timeLabel!.frame = CGRectMake(10, 80, self.view.bounds.size.width-20, 120)
        
        let gap = ( self.view.bounds.size.width - 10*2 - (CGFloat(timeButtons!.count) * 64) ) / CGFloat(timeButtons!.count - 1)
        for (index, button) in (timeButtons!).enumerate() {
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)
            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height-120, 64, 44)
        }
        
        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height-60, self.view.bounds.size.width-20-100, 44)
        clearButton!.frame = CGRectMake(10+self.view.bounds.size.width-20-100+20, self.view.bounds.size.height-60, 80, 44)
        
    }
    
    
    //UI Helpers
    
    func setupTimeLabel() {
        
        timeLabel = UILabel()
        timeLabel!.textColor = UIColor.whiteColor()
        timeLabel!.font = UIFont(name: "Helvetica", size: 60)
        timeLabel!.backgroundColor = UIColor.blackColor()
        timeLabel!.textAlignment = NSTextAlignment.Center
        
        self.view.addSubview(timeLabel!)
    }
    
    func setuptimeButtons() {
        
        var buttons: [UIButton] = []
        for (index, (title, _)) in timeButtonInfos.enumerate() {
            
            let button: UIButton = UIButton()
            button.tag = index // save button's index
            button.setTitle("\(title)", forState: UIControlState.Normal)
            
            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons += [button]
            self.view.addSubview(button)
            
        }
        timeButtons = buttons
        
    }
    
    func setupActionButtons() {
        
        //create start/stop button
        startStopButton = UIButton()
        startStopButton!.backgroundColor = UIColor.redColor()
        startStopButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        startStopButton!.setTitle("Start/Stop", forState: UIControlState.Normal)
        startStopButton!.addTarget(self, action: "startStopButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startStopButton!)
        
        clearButton = UIButton()
        clearButton!.backgroundColor = UIColor.redColor()
        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        clearButton!.setTitle("Reset", forState: UIControlState.Normal)
        clearButton!.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(clearButton!)
        
    }
    
    func setSettingButtonsEnabled(enabled: Bool) {
        for button in self.timeButtons! {
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }
        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
    }
    
    //Actions
    
    func timeButtonTapped(sender: UIButton) {
        let (title, seconds) = timeButtonInfos[sender.tag]
        remainingSeconds += seconds
    }
    
    func startStopButtonTapped(sender: UIButton) {
        isCounting = !isCounting
        
        if isCounting {
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
    }
    
    func clearButtonTapped(sender: UIButton) {
        remainingSeconds = 0
    }
    
    func updateTimer(sender: NSTimer) {
        remainingSeconds -= 1
        
        if remainingSeconds <= 0 {
            let alert = UIAlertView()
            alert.title = "Move your car！"
            alert.message = ""
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
    }
    
    //Helpers
    
    func createAndFireLocalNotificationAfterSeconds(seconds: Int) {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        
        let timeIntervalSinceNow = Double(seconds)
        notification.fireDate = NSDate(timeIntervalSinceNow:timeIntervalSinceNow);
        
        notification.timeZone = NSTimeZone.systemTimeZone();
        notification.alertBody = "Move your car！";
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
        
    }
    
    
}

