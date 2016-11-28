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
        
        let response = Alamofire.request(.GET, "http://zonghanchang571-env.us-west-2.elasticbeanstalk.com/?", parameters: ["symbol": symbol]).responseJSON()
        if let jsonObj = response.result.value {
            json = JSON(jsonObj)
        }
        
        
        if let json = json{
            self.title = json["Symbol"].stringValue
            symbol = json["Symbol"].stringValue
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CurrentViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        loadData()
        setStar(symbol)
    }
    
    func setStar(_ symbol: String) {
        
        if indexOfSymbol(symbol) != -1 {
            if let image = UIImage(named: "star_solid"){
                favoriteIcon.setImage(image, for: UIControlState())
            }
        }
        else {
            if let image = UIImage(named: "star_outline"){
                favoriteIcon.setImage(image, for: UIControlState())
            }
        }
    }
    
    func indexOfSymbol(_ symbol: String) -> Int{
        for i in 0..<favoriteList.count{
            let company = favoriteList[i].value(forKey: "symbol") as? String
            if let company = company {
                if symbol == company {
                    return i
                }
            }
        }
        return -1
    }
    
    func loadData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Symbol")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            favoriteList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        fillTable()
        setChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "historical" {
            let historical: HistoricalViewController = segue.destination as! HistoricalViewController
            historical.symbol = symbol
        }
        
        if segue.identifier == "news" {
            let news: NewsViewController = segue.destination as! NewsViewController
            news.symbol = symbol
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCellTableViewCell
        cell.field?.text = fields[(indexPath as NSIndexPath).row]
        cell.field.font = UIFont.boldSystemFont(ofSize: 12)
        cell.content?.text = content[(indexPath as NSIndexPath).row]
    
        cell.content.font = UIFont.systemFont(ofSize: 12)
        if (indexPath as NSIndexPath).row == 3 {
            if json!["ChangePercent"].doubleValue < 0{
                
                cell.arrow.image = UIImage(named: "Down")
            }
            else{
                cell.arrow.image = UIImage(named: "Up")
            }
        }
        if (indexPath as NSIndexPath).row == 7 {
            if (Double(json!["LastPrice"].stringValue)! - json!["ChangeYTD"].doubleValue) < 0{
                cell.arrow.image = UIImage(named: "Down")
            }
            else{
                cell.arrow.image = UIImage(named: "Up")
            } 
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZZZZZ yyyy"
            let defaultTimeZoneStr = formatter.date(from: dateStr)
            formatter.timeZone = TimeZone(abbreviation: "UTC-04:00")
            formatter.dateFormat = "MMM dd yyyy HH:mm:ss"
            let utcTimeZoneStr = formatter.string(from: defaultTimeZoneStr!)
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
        if let checkedUrl = URL(string: "http://chart.finance.yahoo.com/t?s=\(symbol)&lang=en-US&width=400&height=300") {
            imageView.contentMode = .scaleAspectFit
            downloadImage(checkedUrl)
        }
    }
    
    
    func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
            }) .resume()
    }
    
    func downloadImage(_ url: URL){
        getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data , error == nil else { return }
                
                self.imageView.image = UIImage(data: data)
            }
        }
    }

    
    @IBAction func favorite(_ sender: AnyObject) {
        let index = indexOfSymbol(symbol)
        if index == -1 {
            addFavorite(symbol)
        }
        else {
            deleteFavorite(index)
        }
    }
    
    func deleteFavorite(_ index: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
        managedContext.delete(favoriteList[index] as NSManagedObject)
        favoriteList.remove(at: index)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not delete \(error), \(error.userInfo)")
        }
        setStar(symbol)
    }
    
    func addFavorite(_ symbol: String){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Symbol", in: managedContext)
        
        let favorite = NSManagedObject(entity: entity!, insertInto: managedContext)
        favorite.setValue(symbol, forKey: "symbol")
        
        do {
            try managedContext.save()
            favoriteList.append(favorite)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        setStar(symbol)
    }
    
    
    func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    
    @IBAction func facebook(_ sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://finance.yahoo.com/q?s=" + self.symbol)
        content.contentTitle = "Current Stock Price of \(json!["Name"].stringValue) is $\(json!["LastPrice"].stringValue)"
        content.contentDescription = "Stock Information of \(json!["Name"].stringValue) (\(json!["Symbol"].stringValue))"
        content.imageURL = URL(string: "http://chart.finance.yahoo.com/t?s=\(symbol)&lang=en-US&width=150&height=150")
        
        FBSDKShareDialog.show(from: self, with: content, delegate: self)
        /*
        let dialog:FBSDKShareDialog = FBSDKShareDialog()
        dialog.shareContent = content
        dialog.fromViewController = self
        dialog.delegate = self
        dialog.mode = FBSDKShareDialogMode.FeedBrowser
        dialog.show()
        */
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        let alertController = UIAlertController(title: "Posted Successfully", message:"", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
        let alertController = UIAlertController(title: "Sharing Fail", message:"", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        let alertController = UIAlertController(title: "Not Posted", message:"", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
