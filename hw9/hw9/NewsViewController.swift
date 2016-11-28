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
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewsViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let currentSearchTerm = symbol
        let keyword = "'\(currentSearchTerm)'".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed())!
        let url = URL(string: "https://api.datamarket.azure.com/Bing/Search/v1/News?Query=%27\(keyword)%27&$format=json")!
        
        let credentials = ":M5fYJivsRO3DSFIHKs2bKa4GZZjXkir4AYRTTQGYPi4"
        let plainText = credentials.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let base64 = plainText!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "news", for: indexPath) as! NewsCell
        cell.title.text = self.titles[(indexPath as NSIndexPath).row]
        cell.title.font = UIFont.boldSystemFont(ofSize: 15)
        cell.content.text = self.contents[(indexPath as NSIndexPath).row]
        cell.publisher.text = self.publishers[(indexPath as NSIndexPath).row]
        cell.date.text = self.dates[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.titles.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historical" {
            let historical: HistoricalViewController = segue.destination as! HistoricalViewController
            historical.symbol = symbol
        }
        
        if segue.identifier == "current" {
            let current: CurrentViewController = segue.destination as! CurrentViewController
            current.symbol = symbol
        }

    }
    
    func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.openURL(URL(string: urls[(indexPath as NSIndexPath).row])!)
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
