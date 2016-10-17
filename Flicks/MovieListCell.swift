//
//  MovieListCell.swift
//  Flicks
//
//  Created by Aaron on 10/17/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class MovieListCell: UITableViewCell {
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieDescription: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.image = nil
        movieTitle.text = nil
        movieDescription.text = nil
    }
}
