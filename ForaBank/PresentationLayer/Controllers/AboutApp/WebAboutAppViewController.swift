//
//  WebAboutAppViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 08.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import WebKit

class WebAboutAppViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var urlString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLable.text = urlString
        let request = URLRequest(url: URL(string: "\(urlString)")!)
        webView.load(request)
        webView.navigationDelegate = self
    }
    

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
