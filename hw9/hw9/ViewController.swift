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
import Alamofire_Synchronous
import CoreData


class ViewController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    
    var autoCompleteViewController: AutoCompleteViewController!
    var isFirstLoad: Bool = true
    
    @IBOutlet weak var navigation: UINavigationItem!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let currentSearchTerm = "AAPL"
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
                        
                    }
                }

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
        
        let symbol = (input.substringToIndex(input.rangeOfString("-")!.startIndex))
        
        let response = Alamofire.request(.GET, "http:www-scf.usc.edu/~zonghanc/index.php", parameters: ["input": symbol]).responseJSON()
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

