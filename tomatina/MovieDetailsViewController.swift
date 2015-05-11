//
//  MovieDetailsViewController.swift
//  tomatina
//
//  Created by DeVaris Brown on 5/9/15.
//  Copyright (c) 2015 Furious One. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 400)
        title = movie["title"] as? String
    }
    
    override func viewWillAppear(animated: Bool)
    {
        titleLabel.text = movie["title"] as? String
        ratingLabel.text = movie["mpaa_rating"] as? String
        
        var runtime = movie["runtime"] as! NSNumber
        runtimeLabel.text = "\(runtime) mins"
        synopsisLabel.text = movie["synopsis"] as? String
        
        titleLabel.sizeToFit()
        synopsisLabel.sizeToFit()
        
        var movieUrl = movie.valueForKeyPath("posters.thumbnail") as! String
        
        var range = movieUrl.rangeOfString(".*cloudfront.net/", options:.RegularExpressionSearch)
        if let range = range {
            movieUrl = movieUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        let url = NSURL(string: movieUrl)
        posterView.setImageWithURL(url)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
