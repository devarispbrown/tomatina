//
//  MoviesViewController.swift
//  tomatina
//
//  Created by DeVaris Brown on 5/8/15.
//  Copyright (c) 2015 Furious One. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var movieTable: UITableView!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!

    
    var allMovies: [NSDictionary] = []
    var searchedMovies: [NSDictionary] = []
    
    var refreshControl: UIRefreshControl!
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.hidden = true
        
        self.movieTable.delegate = self
        self.movieTable.dataSource = self
        
        searchBar.delegate = self
        
        title = "Tomatina"
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh:", forControlEvents: .ValueChanged)
        movieTable.insertSubview(refreshControl, atIndex: 0)
        
        fetchData(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var search = self.searchBar
        search.barStyle = UIBarStyle.Black
        search.tintColor = UIColor.whiteColor()
        search.autocapitalizationType = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return searchedMovies.count
        }
        return allMovies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        
        if(searchActive){
            let movie = searchedMovies[indexPath.row]
            cell.titleLabel?.text = movie["title"] as? String
            cell.mpaaLabel.text = movie["mpaa_rating"] as? String
            cell.synopsisLabel.text = movie["synopsis"] as? String
            
            let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
            cell.posterView.setImageWithURL(url)
        } else {
            let movie = allMovies[indexPath.row];
            
            cell.titleLabel.text = movie["title"] as? String
            cell.mpaaLabel.text = movie["mpaa_rating"] as? String
            cell.synopsisLabel.text = movie["synopsis"] as? String
            
            let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
            cell.posterView.setImageWithURL(url)
        }
        
        return cell
    }
    
    func fetchData(showLoadingSpinner: Bool) -> Void {
        let url = NSURL(string:"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")
        let request = NSURLRequest(URL: url!)
        
        bannerView.hidden = true
        
        if showLoadingSpinner {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.refreshControl.endRefreshing()
            
            if error != nil {
                self.displayError(error.localizedDescription)
                return
            }
            
            var json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
            
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode == 403 {
                let message = json["error"] as! String
                self.displayError("\(message)")
            }
            
            self.allMovies = (json["movies"] as? [NSDictionary])!
            self.movieTable.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func displayError(message: String) {
        println(message)
        bannerView.hidden = false
    }
    
    func onRefresh(sender: AnyObject) {
        fetchData(false)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.isEmpty) {
            searchedMovies = allMovies
        } else {
            searchedMovies = allMovies.filter() { (movie: NSDictionary) -> (Bool) in
                var title = movie["title"] as! NSString
                return (title.lowercaseString as NSString).containsString(searchText)
            }
        }
        
        movieTable.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = movieTable.indexPathForCell(cell)!
        
        let movie = allMovies[indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
}
