//
//  ViewController.swift
//  ClosureCallback
//
//  Created by Xu, Jay on 5/10/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var testTableView: UITableView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var dynamicHeight: NSLayoutConstraint!
    
    private var iTunesData = [String]()
    private let downloadFlashingContent = ["Downloading.", "Downloading..", "Downloading..."]
    private var counter = 0
    private var shouldInvalid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testTableView.delegate = self
        testTableView.dataSource = self
        testButton.layer.borderColor = UIColor.grayColor().CGColor
        testButton.layer.borderWidth = 0.5
        idLabel.text = ""
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if iTunesData.count == 0 {
            dynamicHeight.constant = 210
            return 3
        }
        dynamicHeight.constant = 69 * CGFloat(iTunesData.count)
        if dynamicHeight.constant > 470{
            dynamicHeight.constant = 470
        }
        return iTunesData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as! TestCell
        if iTunesData.count > 0{
            cell.myTextField.text = iTunesData[indexPath.row]
            cell.myTextField.userInteractionEnabled = false
        }else {
            cell.shouldUpdateidLabel = {self.updateIdLabel(cell.myTextField.text!)}
            //cell.shouldUpdateidLabel = {() in self.updateIdLabel(cell.myTextField.text!)} full version of line 54
            cell.testClosure1 = {(value: String) in self.updateIdLabel(value)}
            cell.testClosure2 = {(value: String) in self.updateIdLabel(value)}
        }
        return cell
    }
    
    func updateIdLabel(input:String){
        idLabel.text = input
    }

    @IBAction func startFetching(sender: UIButton) {
        shouldInvalid = false
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            DownloadManager().startFetchingDataFromiTunes("https://itunes.apple.com/us/rss/topsongs/limit=10/json") { (result, downloadError) in
                if downloadError != nil {
                    let alert = UIAlertController(title: "Error", message: downloadError!.localizedDescription, preferredStyle: .Alert)
                    let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alert.addAction(cancel)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.shouldInvalid = true
                        self.idLabel.text = "Error"
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.shouldInvalid = true
                        self.iTunesData = result
                        self.testTableView.reloadData()
                        self.idLabel.text = "Finished!"
                    })
                }
            }
        }
    }
    
    func updateLabel(sender:NSTimer){
        if shouldInvalid {
            sender.invalidate()
        }else {
            self.idLabel.text = downloadFlashingContent[counter]
            counter += 1
            if counter == 3{
                counter = 0
            }
        }
    }
    
    func testReachability(hostName: String?) -> Bool{
        var reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.apple.com")
        if hostName != nil {
            reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, hostName!)
        }
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        
        if SCNetworkReachabilityGetFlags(reachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

