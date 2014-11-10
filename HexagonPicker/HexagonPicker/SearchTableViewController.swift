//
//  SearchTableViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 08.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class SearchTableViewController: ArtToolbarViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate {
    
    let cellHeihgt: CGFloat = 44

    var searchArts: [Art] = []
    let searchBarHeight: CGFloat = 40
    var searchBar: UISearchBar?
    var searchController: UISearchDisplayController?
    
    var tableView: UITableView = UITableView()
    var searchResultsTableView: UITableView?
    
    var mainSubview: UIView = UIView()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.blackColor()
        tableView.tableFooterView = UIView()
        mainSubview.addSubview(tableView)
        tableView.registerNib(UINib(nibName: "ArtCell", bundle: nil), forCellReuseIdentifier: "artCell")
        scrollView = tableView
        super.viewDidLoad()
        
        searchBar = UISearchBar()
        searchBar!.delegate = self
        
        searchController = UISearchDisplayController(searchBar: searchBar!, contentsController: self)
        searchController!.delegate = self
        searchController!.searchResultsDataSource = self
        searchController!.searchResultsDelegate = self
        mainSubview.addSubview(searchBar!)
        
        view.addSubview(mainSubview)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        super.viewWillLayoutSubviews()
        scrollView!.frame = screenSize!
        initNavigationBar()
        updateSubviews()
    }
    
    
    
    override func updateView() -> Bool {
        if super.updateView() {
            updateSubviews()
        }
        return true
    }
    
    
    
    func updateSubviews() {
        mainSubview.frame = screenSize!
        if deviceOrientationLandscape {
            mainSubview.frame.size.width -= buttonsToolbarHeight
        } else {
            mainSubview.frame.size.height -= buttonsToolbarHeight
        }
        
        tableView.frame = mainSubview.frame
        tableView.frame.origin.y = searchBarHeight
        searchBar!.frame = mainSubview.frame
        searchBar!.frame.size.height = searchBarHeight
        if !deviceOrientationLandscape {
            tableView.frame.size.height -= buttonsToolbarHeight
        }
    }
    
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    
    
    override func homeButtonPressed() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    
    override func searchButtonPressed() {
    }


    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArts.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("artCell") as? ArtViewCell
        if cell == nil {
            cell = ArtViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "artCell")
        }
        cell!.artistName.text = searchArts[indexPath.row].artist!.name
        cell!.cityLabel.text = searchArts[indexPath.row].city
        cell!.artImage.image = searchArts[indexPath.row].iconImage
        return cell!
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let artViewController = ArtViewController()
        artViewController.art = searchArts[indexPath.row]
        artViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        artViewController.transitioningDelegate = self
        presentViewController(artViewController, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
    }

    
    
    func filterContentForSearchText(searchText: String) {
        self.searchArts = arts.filter({$0.artist!.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
            $0.city.lowercaseString.rangeOfString(searchText.lowercaseString) != nil})
    }
    
    
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchArts.removeAll(keepCapacity: false)
        searchArts = []
        searchResultsTableView = nil
        self.tableView.reloadData()
    }
    
    
    
    func searchDisplayControllerDidBeginSearch(controller: UISearchDisplayController) {
        searchResultsTableView = controller.searchResultsTableView
        searchResultsTableView!.backgroundColor = UIColor.blackColor()
        searchResultsTableView!.tableFooterView = UIView()
    }
    
    
    
    func searchDisplayController(controller: UISearchDisplayController, didShowSearchResultsTableView tableView: UITableView) {
        view.bringSubviewToFront(buttonsToolbarView!)
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeihgt
    }

}
