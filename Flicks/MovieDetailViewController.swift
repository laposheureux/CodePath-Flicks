//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Aaron on 10/16/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var movieReleaseDateLabel: UILabel!
    @IBOutlet var moviePopularityLabel: UILabel!
    @IBOutlet var movieOverviewLabel: UILabel!
    @IBOutlet var detailScrollView: UIScrollView!
    
    var movieTitle: String?
    var releaseDate: String?
    var popularity: Double?
    var overview: String?
    var lowBackdropPath: URL?
    var fullBackdropPath: URL?
    let unknownPopularity: String = "0.0"
    
    func calculateHeightOfContents() -> CGFloat {
        // Take the vertically lowest element and get its frame's y origin and its height and add that to the offset of the title from the top to make the top and bottom padding equal
        return movieOverviewLabel.frame.origin.y + movieOverviewLabel.bounds.size.height + movieTitleLabel.frame.origin.y
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movieTitle
        movieTitleLabel.text = movieTitle
        moviePopularityLabel.text = "Popularity: \(popularity?.rounded(.up).description ?? unknownPopularity)%"
        movieOverviewLabel.text = overview
        
        if let releaseDate = releaseDate {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            let date = inputFormatter.date(from: releaseDate)
            if let date = date {
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .long
                movieReleaseDateLabel.text = outputFormatter.string(from: date)
            }
        }
        
        if let lowBackdropPath = lowBackdropPath {
            backdropImageView.setImageWith(URLRequest(url: lowBackdropPath), placeholderImage: nil, success: { [weak self] req, resp, image in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if let fullBackdropPath = self?.fullBackdropPath {
                        self?.backdropImageView.setImageWith(fullBackdropPath, placeholderImage: image)
                    }
                }
            }, failure: nil)
        }
        
        movieTitleLabel.frame = CGRect(origin: CGPoint(x: 8, y: 16), size: CGSize(width: view.bounds.width - 40, height: movieTitleLabel.frame.size.height))
        moviePopularityLabel.frame = CGRect(origin: CGPoint(x: view.bounds.width - 40 - moviePopularityLabel.bounds.size.width, y: moviePopularityLabel.frame.origin.y), size: moviePopularityLabel.bounds.size)
        movieOverviewLabel.frame = CGRect(origin: CGPoint(x: 8, y: movieOverviewLabel.frame.origin.y), size: movieOverviewLabel.sizeThatFits(CGSize(width: view.bounds.width - 48, height: 600)))
        detailScrollView.frame = CGRect(origin: CGPoint(x: 8, y: view.bounds.height - 150), size: CGSize(width: view.bounds.width - 16, height: 150))
        detailScrollView.contentSize = CGSize(width: view.bounds.width - 16, height: calculateHeightOfContents())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

