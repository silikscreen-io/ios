//
//  LoginWebViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 20.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class LoginWebViewController: UIViewController, UIWebViewDelegate, ArtFeedViewControllerDelegate {
    
    let baseURL = "https://instagram.com/"
    let instagramAPIBaseURL = "https://api.instagram.com"
    let clientID = "3e334386068c4aa7b574697ed6caeba4"
    let redirectURI = "http://silkscreen.io"
        //let authenticationURL = baseURL + "oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=token&scope=likes+comments+basic"
        //https://instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=token
        //let authenticationURL = instagramAPIBaseURL + "/oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code"
    var requestURL = ""
    
    var token: NSString?

    
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        requestURL = baseURL + "oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=token&scope=basic+likes"
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        login()
    }
    
    
    
    func login() {
        let request = NSURLRequest(URL: NSURL(string: requestURL)!)
        webView.loadRequest(request)
    }
    
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var urlString: NSString = request.URL.absoluteString!
        var url = request.URL
        var urlParts = url.pathComponents as [String]
        // do any of the following here
//        println(urlString)
        //if ([urlString hasPrefix: @"localhost"]) {
        var tokenParam = urlString.rangeOfString("access_token=")
        if tokenParam.location != NSNotFound {
            token = urlString.substringFromIndex(NSMaxRange(tokenParam))
            // If there are more args, don't include them in the token:
            var endRange = token!.rangeOfString("&")
            if endRange.location != NSNotFound {
                token = token!.substringToIndex(endRange.location)
            }
            let urlUser = NSURL(string: "https://api.instagram.com/v1/users/self/?access_token=\(token!)")
            let request = NSURLRequest(URL: urlUser!)
            var error: NSError?
            var response: NSURLResponse?
            let reply = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
            let requestData = NSJSONSerialization.JSONObjectWithData(reply!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            currentUser = User(requestData["data"] as NSDictionary)
            self.performSegueWithIdentifier("showArtFeedSegue", sender: self)
            return false
        } else {
            // Handle the access rejected case here.
//            println("rejected case, user denied request")
        }
        return true
    }
    
    
    
    func dismissArtFeedViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
        token = nil
//        var cookie = NSHTTPCookie()
        var storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies as [NSHTTPCookie] {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        //requestURL = "https://instagram.com/accounts/logout/"
        login()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArtFeedSegue" {
            let artFeedViewController = segue.destinationViewController as ArtFeedViewController
            artFeedViewController.delegate = self
        }
    }

}
