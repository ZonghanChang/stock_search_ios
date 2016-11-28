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
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(HistoricalViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.title = symbol
        let localfilePath = Bundle.main.url(forResource: "historical", withExtension: "html");
        let myRequest = URLRequest(url: localfilePath!);
        
        historicalChart.loadRequest(myRequest);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        historicalChart.stringByEvaluatingJavaScript(from: "PlotChart('" + symbol + "')")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "current" {
            let current: CurrentViewController = segue.destination as! CurrentViewController
            current.symbol = symbol
        }
        
        if segue.identifier == "news" {
            let news: NewsViewController = segue.destination as! NewsViewController
            news.symbol = symbol
        }
    }
    
    func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
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
