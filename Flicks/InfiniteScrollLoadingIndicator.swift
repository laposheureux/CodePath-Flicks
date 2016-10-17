//
//  InfiniteScrollLoadingIndicator
//  Flicks
//
//  Created by Aaron on 10/17/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class InfiniteScrollLoadingIndicator: UIView {
    static let defaultHeight: CGFloat = 40
    
    let activityIndicatorView = UIActivityIndicatorView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }
    
    func startAnimating() {
        isHidden = false
        activityIndicatorView.startAnimating()
    }
}
