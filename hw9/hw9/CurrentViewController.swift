//
//  CurrentViewController.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 4/25/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Alamofire_Synchronous
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class CurrentViewController: UIViewController, UITableViewDataSource, FBSDKSharingDelegate {
    var json: JSON?
    var symbol: String = ""
    var favoriteList = [NSManagedObject]()
    @IBOutlet weak var table: UITableView!
        
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var favoriteIcon: UIButton!
    

    
    let fields = ["Name", "Symbol", "Last Price", "Change", "Time and Date", "Market Cap", "Volume", "Change YTD", "High Price", "Low Price", "Opening Price"]
    var content = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let response = Alamofire.request(.GET, "http:www-scf.usc.edu/~zonghanc/index.php", parameters: ["symbol": symbol]).responseJSON()
        if let jsonObj = response.result.value {
            json = JSON(jsonObj)
        }
        
        
        if let json = json{
            self.title = json["Symbol"].stringValue
            symbol = json["Symbol"].stringValue
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CurrentViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        loadData()
        setStar(symbol)
    }
    
    func setStar(symbol: String) {
        
        if indexOfSymbol(symbol) != -1 {
            if let image = UIImage(named: "star_solid"){
                favoriteIcon.setImage(image, forState: .Normal)
            }
        }
        else {
            if let image = UIImage(named: "star_outline"){
                favoriteIcon.setImage(image, forState: .Normal)
            }
        }
    }
    
    func indexOfSymbol(symbol: String) -> Int{
        for i in 0..<favoriteList.count{
            let company = favoriteList[i].valueForKey("symbol") as? String
            if let company = company {
                if symbol == company {
                    return i
                }
            }
        }
        return -1
    }
    
    func loadData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Symbol")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            favoriteList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        fillTable()
        setChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "historical" {
            let historical: HistoricalViewController = segue.destinationViewController as! HistoricalViewController
            historical.symbol = symbol
        }
        
        if segue.identifier == "news" {
            let news: NewsViewController = segue.destinationViewController as! NewsViewController
            news.symbol = symbol
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detail", forIndexPath: indexPath) as! DetailCellTableViewCell
        
        cell.field?.text = fields[indexPath.row]
        cell.field.font = UIFont.boldSystemFontOfSize(12)
        cell.content?.text = content[indexPath.row]
    
        cell.content.font = UIFont.systemFontOfSize(12)
        if indexPath.row == 3 {
            if json!["ChangePercent"].doubleValue < 0{
                
                cell.arrow.image = UIImage(named: "Down")
            }
            else{
                cell.arrow.image = UIImage(named: "Up")
            }
        }
        if indexPath.row == 7 {
            if (Double(json!["LastPrice"].stringValue)! - json!["ChangeYTD"].doubleValue) < 0{
                cell.arrow.image = UIImage(named: "Down")
            }
            else{
                cell.arrow.image = UIImage(named: "Up")
            } 
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func fillTable(){
        if let json = json{
            if json["Status"].stringValue == "SUCCESS" {
            content.append(json["Name"].stringValue)
            content.append(json["Symbol"].stringValue)
            content.append("$ " + json["LastPrice"].stringValue)
            content.append(String(format: "%.2f", json["Change"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercent"].doubleValue) + "%)")
            
            let dateStr = json["Timestamp"].stringValue
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZZZZZ yyyy"
            let defaultTimeZoneStr = formatter.dateFromString(dateStr)
            formatter.timeZone = NSTimeZone(abbreviation: "UTC-04:00")
            formatter.dateFormat = "MMM dd yyyy HH:mm:ss"
            let utcTimeZoneStr = formatter.stringFromDate(defaultTimeZoneStr!)
            content.append(utcTimeZoneStr)
            
            let marketcap = json["MarketCap"].doubleValue
            if marketcap / 1000000000 >= 0.005 {
                content.append(String(format: "%.2f", marketcap / 1000000000) + " Billion")
            }
            else if marketcap / 1000000 >= 0.05{
                content.append(String(format: "%.2f", marketcap / 1000000) + " Million")
            }
            else{
                content.append(String(marketcap))
            }
            
            content.append(json["Volume"].stringValue)
            content.append(String(format: "%.2f", Double(json["LastPrice"].stringValue)! - json["ChangeYTD"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercentYTD"].doubleValue) + "%)")
            content.append("$ " + String(json["High"].doubleValue))
            content.append("$ " + String(json["Low"].doubleValue))
            content.append("$ " + String(json["Open"].doubleValue))
            }
        }
        
    }
    
    
    func setChart(){
        if let checkedUrl = NSURL(string: "http://chart.finance.yahoo.com/t?s=\(symbol)&lang=en-US&width=400&height=300") {
            imageView.contentMode = .ScaleAspectFit
            downloadImage(checkedUrl)
        }
    }
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                
                self.imageView.image = UIImage(data: data)
            }
        }
    }

    
    @IBAction func favorite(sender: AnyObject) {
        let index = indexOfSymbol(symbol)
        if index == -1 {
            addFavorite(symbol)
        }
        else {
            deleteFavorite(index)
        }
    }
    
    func deleteFavorite(index: Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
        managedContext.deleteObject(favoriteList[index] as NSManagedObject)
        favoriteList.removeAtIndex(index)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not delete \(error), \(error.userInfo)")
        }
        setStar(symbol)
    }
    
    func addFavorite(symbol: String){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Symbol", inManagedObjectContext: managedContext)
        
        let favorite = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        favorite.setValue(symbol, forKey: "symbol")
        
        do {
            try managedContext.save()
            favoriteList.append(favorite)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        setStar(symbol)
    }
    
    
    func back(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    
    @IBAction func facebook(sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s=" + self.symbol)
        content.contentTitle = "Current Stock Price of \(json!["Name"].stringValue) is $\(json!["LastPrice"].stringValue)"
        content.contentDescription = "Stock Information of \(json!["Name"].stringValue) (\(json!["Symbol"].stringValue))"
        content.imageURL = NSURL(string: "http://chart.finance.yahoo.com/t?s=\(symbol)&lang=en-US&width=150&height=150")
        
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        /*
        let dialog:FBSDKShareDialog = FBSDKShareDialog()
        dialog.shareContent = content
        dialog.fromViewController = self
        dialog.delegate = self
        dialog.mode = FBSDKShareDialogMode.FeedBrowser
        dialog.show()
        */
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        let alertController = UIAlertController(title: "Sharing Completed", message:"", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
        let alertController = UIAlertController(title: "Sharing Fail", message:"", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        let alertController = UIAlertController(title: "Sharing Cancelled", message:"", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
