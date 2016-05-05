//
//  NewsViewController.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 4/25/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_Synchronous
import SwiftyJSON

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var symbol: String = ""
    var titles = [String]()
    var contents = [String]()
    var publishers = [String]()
    var dates = [String]()
    var urls = [String]()
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = symbol
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewsViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let currentSearchTerm = symbol
        let keyword = "'\(currentSearchTerm)'".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let url = NSURL(string: "https://api.datamarket.azure.com/Bing/Search/v1/News?Query=%27\(keyword)%27&$format=json")!
        
        let credentials = ":M5fYJivsRO3DSFIHKs2bKa4GZZjXkir4AYRTTQGYPi4"
        let plainText = credentials.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let base64 = plainText!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let headers = [
            "Authorization": "Basic \(base64)"
        ]
        Alamofire.request(.GET, url, headers: headers)
            .responseJSON { response in
                if let jsonObj = response.result.value {
                    let json = JSON(jsonObj)["d"]["results"]
                    for (_,value) : (String, JSON) in json{
                        self.titles.append(value["Title"].stringValue)
                        self.contents.append(value["Description"].stringValue)
                        self.publishers.append(value["Source"].stringValue)
                        self.dates.append(value["Date"].stringValue)
                        self.urls.append(value["Url"].stringValue)
                    }
                }
                self.table.reloadData()
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("news", forIndexPath: indexPath) as! NewsCell
        cell.title.text = self.titles[indexPath.row]
        cell.title.font = UIFont.boldSystemFontOfSize(15)
        cell.content.text = self.contents[indexPath.row]
        cell.publisher.text = self.publishers[indexPath.row]
        cell.date.text = self.dates[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.titles.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "historical" {
            let historical: HistoricalViewController = segue.destinationViewController as! HistoricalViewController
            historical.symbol = symbol
        }
        
        if segue.identifier == "current" {
            let current: CurrentViewController = segue.destinationViewController as! CurrentViewController
            current.symbol = symbol
        }

    }
    
    func back(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(NSURL(string: urls[indexPath.row])!)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
