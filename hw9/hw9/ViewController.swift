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
    
    var autoRefreshTimer = Timer()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favoriteTable.reloadData()
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
            let alertController = UIAlertController(title: "Please Enter a Stock Name or Symbol", message:"", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        
        let input = inputField.text!
        
        var symbol: String = String()
        if let _ = input.range(of: "-"){
            symbol = input.substring(to: input.range(of: "-")!.lowerBound)
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
                let alertController = UIAlertController(title: "Invalid Symbol", message:"", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }
    

    var symbol: String = ""
    @IBAction func getQuote(_ sender: UIButton) {
        if validate() {
            let input = inputField.text!
            if input.characters.count > 2 {
                symbol = (input.substring(to: input.range(of: "-")!.lowerBound))
            }
            else {
                symbol = input
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let current: CurrentViewController = segue.destination as! CurrentViewController
        
        if segue.identifier == "current" {
            current.symbol = symbol
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favorites", for: indexPath) as! FavoriteCell
        let symbol = favoriteList[(indexPath as NSIndexPath).row].value(forKey: "symbol") as? String
        
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
                
                
                cell.change.textColor = UIColor.white
                
                if json["Change"].doubleValue < 0 {
                    cell.change.text = (String(format: "%.2f", json["Change"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercent"].doubleValue) + "%)")
                    cell.change.backgroundColor = UIColor.red
                }
                else {
                    cell.change.text = ("+" + String(format: "%.2f", json["Change"].doubleValue) + "(" + String(format: "%.2f", json["ChangePercent"].doubleValue) + "%)")
                    cell.change.backgroundColor = UIColor.green
                }
                
            }

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }

    @IBAction func refresh(_ sender: AnyObject) {
        refreshOnce()
        
    }
    
    @IBAction func autoRefreshChange(_ sender: AnyObject) {
        
        if autoRefreshSwitch.isOn {
             autoRefreshTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(ViewController.refreshOnce), userInfo: nil, repeats: true)
        }
        else{
            
            autoRefreshTimer.invalidate()
            
        }
    }
    
    func refreshOnce() {
        indicator.startAnimating()
        self.favoriteTable.reloadData()
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time){
            
            self.indicator.stopAnimating()
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext
            managedContext.delete(favoriteList[(indexPath as NSIndexPath).row] as NSManagedObject)
            favoriteList.remove(at: (indexPath as NSIndexPath).row)
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not delete \(error), \(error.userInfo)")
            }
            favoriteTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! FavoriteCell
        symbol = currentCell.symbol.text!
        self.performSegue(withIdentifier: "current", sender: self)

    }
    
    
}

extension ViewController: AutocompleteDelegate {
    func autoCompleteTextField() -> UITextField {
        return self.inputField
    }
    func autoCompleteThreshold(_ textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteItemsForSearchTerm(_ term: String) -> [AutocompletableOption] {
        var symbolList = Dictionary<String, String>()
        let response = Alamofire.request(.GET, "http:www-scf.usc.edu/~zonghanc/index.php", parameters: ["input": term]).responseJSON()
        if let jsonObj = response.result.value {
            let json = JSON(jsonObj)
            for (_,value) : (String, JSON) in json{
                symbolList[value["Symbol"].stringValue + "-" + value["Name"].stringValue + "-" + value["Exchange"].stringValue] = value["Symbol"].stringValue
            }
        }
        
        let symbolCellList: [AutocompletableOption] = symbolList.map { (name, sym) -> AutocompleteCellData in
            return AutocompleteCellData(text: name,symbol:sym , image:nil)
            }.map( { $0 as AutocompletableOption })
        return symbolCellList
    }
    
    func autoCompleteHeight() -> CGFloat {
        return self.view.frame.height / 3.0
    }
    
    
    func didSelectItem(_ item: AutocompletableOption) {
        
    }
}

