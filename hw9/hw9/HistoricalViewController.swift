//
//  HistoricalViewController.swift
//  hw9
//
//  Created by ZONGHAN CHANG on 4/25/16.
//  Copyright © 2016 ZONGHAN CHANG. All rights reserved.
//

import UIKit

class HistoricalViewController: UIViewController,UIWebViewDelegate {
    var symbol: String = ""
    
    
    @IBOutlet weak var historicalChart: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let localfilePath = NSBundle.mainBundle().URLForResource("historical", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        
        historicalChart.loadRequest(myRequest);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        historicalChart.stringByEvaluatingJavaScriptFromString("PlotChart('" + symbol + "')")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "current" {
            let current: CurrentViewController = segue.destinationViewController as! CurrentViewController
            current.symbol = symbol
        }
        
        if segue.identifier == "news" {
            let news: NewsViewController = segue.destinationViewController as! NewsViewController
            news.symbol = symbol
        }
    }
    
    func back(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
