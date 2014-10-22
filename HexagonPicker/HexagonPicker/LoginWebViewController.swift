//
//  LoginWebViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 20.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class LoginWebViewController: UIViewController, UIWebViewDelegate {
    
    let baseURL = "https://instagram.com/"
    let instagramAPIBaseURL = "https://api.instagram.com"
    let clientID = "3e334386068c4aa7b574697ed6caeba4"
    let redirectURI = "http://silkscreen.io"

    
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        //let authenticationURL = baseURL + "oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=token&scope=likes+comments+basic"
        let authenticationURL = baseURL + "oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=token&scope=basic+likes"
        //https://instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=token
        //let authenticationURL = instagramAPIBaseURL + "/oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code"
        let request = NSURLRequest(URL: NSURL(string: authenticationURL)!)
        webView.loadRequest(request)
    }
    
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var urlString: NSString = request.URL.absoluteString!
        var url = request.URL
        var urlParts = url.pathComponents as [String]
        // do any of the following here
        println(urlString)
        if urlParts[1] == "MAMP" {
            //if ([urlString hasPrefix: @"localhost"]) {
            var tokenParam = urlString.rangeOfString("access_token=")
            if tokenParam.location != NSNotFound {
                var token: NSString = urlString.substringFromIndex(NSMaxRange(tokenParam))
                // If there are more args, don't include them in the token:
                var endRange = token.rangeOfString("&")
                if endRange.location != NSNotFound {
                    token = token.substringToIndex(endRange.location)
                }
                
                println("access token \(token)")
//                if token.length > 0 ) {
//                    // display the photos here
////                    instagramTableViewController *iController = [[instagramPhotosTableViewController alloc] initWithStyle:UITableViewStylePlain];
//                    NSString* redirectUrl = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", token];
//                }
                // use delegate if you want
                //[self.delegate instagramLoginSucceededWithToken: token];
                
            }
            else {
                // Handle the access rejected case here.
                println("rejected case, user denied request")
            }
            return false
        }
        return true
    }

}
