//
//  DownloadManager.swift
//  ClosureCallback
//
//  Created by Xu, Jay on 5/10/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
    private func configureEnvironment(urlString: String, completionHandler:(([String], NSError?)->Void)){
        var dataArr = [String]()
        let targetUrl = NSURL(string: urlString)
        let request = NSURLRequest(URL: targetUrl!)
        let session = NSURLSession.sharedSession()
        let download = session.downloadTaskWithRequest(request) { (location, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                dataArr.append("Error Happened")
            }else {
                let startDict = try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: location!)!, options: .AllowFragments)
                let feedDict = startDict!["feed"] as! [String: AnyObject]
                let entryArr = feedDict["entry"] as! [AnyObject]
                for dic in entryArr{
                    let nameDict = dic["im:name"] as! [String: AnyObject]
                    let name = nameDict["label"] as! String
                    dataArr.append(name)
                }
            }
            completionHandler(dataArr, error)
        }
        download.resume()
    }
    
    func startFetchingDataFromiTunes(urlString: String, handler:(([String], NSError?)->Void)){
        configureEnvironment( urlString , completionHandler: {(result, error) in
            handler(result,error)
        })
    }
}
