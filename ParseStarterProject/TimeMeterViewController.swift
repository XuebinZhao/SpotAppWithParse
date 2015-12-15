//
//  TimeMeterViewController.swift
//  SpotAppParse
//
//  Created by xbin on 12/15/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class TimeMeterViewController: UIViewController {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    ///UI Controls
    
    //var timeLabel: UILabel?         // Show remaining time
    //var startStopButton: UIButton?  // Start/Stop button
    //var clearButton: UIButton?      // Reset button
//    var timeButtons: [UIButton]?    // Buttons for setting time values
//    let timeButtonInfos = [("10Min", 600), ("15Min", 900), ("30Min", 1800), ("1hour", 3600)]
    
    
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
            //setSettingButtonsEnabled(!newValue)
            clearButton.enabled = !newValue
            clearButton.alpha = !newValue ? 1.0 : 0.3
        }
    }
    
    @IBAction func startStopButtonTapped(sender: AnyObject) {
        isCounting = !isCounting
        
        if isCounting {
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
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
    
    func createAndFireLocalNotificationAfterSeconds(seconds: Int) {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        
        let timeIntervalSinceNow = Double(seconds)
        notification.fireDate = NSDate(timeIntervalSinceNow:timeIntervalSinceNow);
        
        notification.timeZone = NSTimeZone.systemTimeZone();
        notification.alertBody = "Move your car！";
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
        
    }
    
    @IBAction func m10TimeButtonTapped(sender: AnyObject) {remainingSeconds += 10}
    @IBAction func m15TimeButtonTapped(sender: AnyObject) {remainingSeconds += 900}
    @IBAction func m30TimeButtonTapped(sender: AnyObject) {remainingSeconds += 1800}
    @IBAction func h1TimeButtonTapped(sender: AnyObject) {remainingSeconds += 3600}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
