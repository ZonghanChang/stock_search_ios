//
//  ViewController.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 4/23/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit
import CCAutocomplete
import Alamofire
import SwiftyJSON
import CoreData


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var inputField: UITextField!
    
    var autoCompleteViewController: AutoCompleteViewController!
    var isFirstLoad: Bool = true
    var favoriteList = [NSManagedObject]()
    
    @IBOutlet weak var favoriteTable: UITableView!
    
    @IBOutlet weak var autoRefreshSwitch: UISwitch!
    
    @IBOutlet weak var navigation: UINavigationItem!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var autoRefreshTimer = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        favoriteTable.reloadData()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    func validate() -> Bool {
        if (inputField.text == ""){
            let alertController = UIAlertController(title: "Please Enter a Stock Name or Symbol", message:"", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        
        let input = inputField.text!
        
        var symbol: String = String()
        if let _ = input.rangeOfString("-"){
            symbol = input.substringToIndex(input.rangeOfString("-")!.startIndex)
        }
        else{
            symbol = input
        }
        let response = Alamofire.request(.GET, "http://zonghanchang571-env.us-west-2.elasticbeanstalk.com/?", parameters: ["input": symbol]).responseJSON()
        if let jsonObj = response.result.value {
            let json = JSON(jsonObj)
            if let _ = json[0]["Symbol"].string {
                return true
            }
            else{
                let alertController = UIAlertController(title: "Invalid Symbol", message:"", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }
    

    var symbol: String = ""
    @IBAction func getQuote(sender: UIButton) {
        if validate() {
            let input = inputField.text!
            symbol = (input.substringToIndex(input.rangeOfString("-")!.startIndex))
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let current: CurrentViewController = segue.destinationViewController as! CurrentViewController
        
        if segue.identifier == "current" {
            current.symbol = symbol
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favorites", forIndexPath: indexPath) as! FavoriteCell
        let symbol = favoriteList[indexPath.row].valueForKey("symbol") as? String
        
        Alamofire.request(.GET, "http://zonghanchang571-env.us-west-2.elasticbeanstalk.com/?", parameters: ["symbol": symbol!]).responseJSON(){ response in
            if let jsonObj = response.result.value {
                let json = JSON(jsonObj)
                cell.symbol.text = json["Symbol"].stringValue
                cell.name.text = json["Name"].stringValue
                cell.price.text = "$ \(json["LastPrice"].stringValue)"
                
                var cap: String = ""
                let marketcap = json["MarketCap"].doubleValue
                if marketcap / 1000000000 >= 0.005 {
                    cap = (String(format: "%.2f", marketcap / 1000000000) + " Billion")
                }
                else if marketcap / 1000000 >= 0.05{
                    cap = (String(format: "%.2f", marketcap / 1000000) + " Million")
                }
                else{
                    cap = (String(marketcap))
                }
                cell.cap.text = "Market Cap: \(cap)"
                
                
                cell.change.textColor = UIColor.whiteColor()
                
                if json["Change"].doubleValue < 0 {
                    cell.change.text = (String(format: "%.2f", json["Change"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercent"].doubleValue) + "%)")
                    cell.change.backgroundColor = UIColor.redColor()
                }
                else {
                    cell.change.text = ("+" + String(format: "%.2f", json["Change"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercent"].doubleValue) + "%)")
                    cell.change.backgroundColor = UIColor.greenColor()
                }
                
            }

        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }

    @IBAction func refresh(sender: AnyObject) {
        refreshOnce()
        
    }
    
    @IBAction func autoRefreshChange(sender: AnyObject) {
        
        if autoRefreshSwitch.on {
             autoRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(ViewController.refreshOnce), userInfo: nil, repeats: true)
        }
        else{
            
            autoRefreshTimer.invalidate()
            
        }
    }
    
    func refreshOnce() {
        indicator.startAnimating()
        let delay = 0.001 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        //dispatch_after(time, dispatch_get_main_queue()){
            self.favoriteTable.reloadData()
            self.indicator.stopAnimating()
        //}
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            managedContext.deleteObject(favoriteList[indexPath.row] as NSManagedObject)
            favoriteList.removeAtIndex(indexPath.row)
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not delete \(error), \(error.userInfo)")
            }
            favoriteTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! FavoriteCell
        symbol = currentCell.symbol.text!
        self.performSegueWithIdentifier("current", sender: self)

    }
    
    
}

extension ViewController: AutocompleteDelegate {
    func autoCompleteTextField() -> UITextField {
        return self.inputField
    }
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        var symbolList = Dictionary<String, String>()
        let response = Alamofire.request(.GET, "http:www-scf.usc.edu/~zonghanc/index.php", parameters: ["input": term]).responseJSON()
        if let jsonObj = response.result.value {
            let json = JSON(jsonObj)
            for (_,value) : (String, JSON) in json{
                symbolList[value["Symbol"].stringValue + "-" + value["Name"].stringValue + "-" + value["Exchange"].stringValue] = value["Symbol"].stringValue
            }
        }
        
        let symbolCellList: [AutocompletableOption] = symbolList.map { (let name, let sym) -> AutocompleteCellData in
            return AutocompleteCellData(text: name,symbol:sym , image:nil)
            }.map( { $0 as AutocompletableOption })
        return symbolCellList
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    
    
    func didSelectItem(item: AutocompletableOption) {
        
    }
}

