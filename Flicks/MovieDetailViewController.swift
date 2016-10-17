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
    
    var movieTitle: String?
    var releaseDate: String?
    var popularity: Double?
    var overview: String?
    var lowBackdropPath: URL?
    var fullBackdropPath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movieTitle
        
        if let lowBackdropPath = lowBackdropPath {
            backdropImageView.setImageWith(URLRequest(url: lowBackdropPath), placeholderImage: nil, success: { [weak self] req, resp, image in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if let fullBackdropPath = self?.fullBackdropPath {
                        self?.backdropImageView.setImageWith(fullBackdropPath, placeholderImage: image)
                    }
                }
            }, failure: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

