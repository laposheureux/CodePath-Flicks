//
//  MovieListViewController.swift
//  Flicks
//
//  Created by Aaron on 10/16/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

enum MovieImageType {
    case Poster
    case Backdrop
}

enum MovieImageQuality {
    case Low(MovieImageType)
    case High(MovieImageType)
    
    var pathComponent: String {
        switch self {
        case .Low(let imageType):
            return imageType == .Poster ? "w92" : "w300"
        case .High(let imageType):
            return imageType == .Poster ? "w342" : "original"
        }
    }
}

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet var movieList: UITableView!
    @IBOutlet var errorLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    private let infiniteScrollLoadingIndicator = InfiniteScrollLoadingIndicator()
    private var loading: Bool = false {
        didSet {
            if loading {
                if refreshControl.isRefreshing {
                    SVProgressHUD.show()
                } else {
                    infiniteScrollLoadingIndicator.startAnimating()
                }
            } else {
                if refreshControl.isRefreshing {
                    SVProgressHUD.dismiss()
                    refreshControl.endRefreshing()
                } else {
                    infiniteScrollLoadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    private var movieData: [JSON] = []
    private var currentPageFetched = 0
    
    func imageURLForFilename(filename: String?, andQuality quality: MovieImageQuality) -> URL? {
        guard let filename = filename else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(quality.pathComponent)\(filename)")
    }
    
    func refreshMovieData() {
        currentPageFetched = 0
        movieData.removeAll()
        fetchMovieDataForNextPage()
    }
    
    func fetchMovieDataForNextPage() {
        let nextPage = currentPageFetched + 1
        
        loading = true
        
        APINetworking.sharedInstance.fetchNowPlayingMovies(page: nextPage, completionBlock: { [weak self] jsonArray in
            self?.movieData += jsonArray
            self?.currentPageFetched = nextPage
            self?.movieList.reloadData()
            self?.loading = false
        }) { [weak self] error in
            self?.loading = false
            self?.errorLabel.text = error.description
            self?.errorLabel.alpha = 1
            self?.errorLabel.isHidden = false
            
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { timer in
                UIView.animate(withDuration: 0.5, animations: {
                    self?.errorLabel.alpha = 0
                }) { success in
                    // Whether or not it succeeded, hide it
                    self?.errorLabel.isHidden = true
                }
            }
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !loading {
            let tableViewThreshold = movieList.contentSize.height - movieList.bounds.size.height
            
            if scrollView.contentOffset.y > tableViewThreshold && movieList.isDragging {
                fetchMovieDataForNextPage()
                
                let loaderFrame = CGRect(x: 0, y: movieList.contentSize.height, width: movieList.bounds.size.width, height: InfiniteScrollLoadingIndicator.defaultHeight)
                infiniteScrollLoadingIndicator.frame = loaderFrame
                infiniteScrollLoadingIndicator.startAnimating()
            }
        }
    }
    
    
    // MARK: - UITableViewDelegate/UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListItem", for: indexPath) as! MovieListCell
        let cellData = movieData[indexPath.row]
        
        cell.selectionStyle = .none
        
        cell.movieTitle.text = cellData["title"].string
        cell.movieDescription.text = cellData["overview"].string
        
        if let lowFullURL = imageURLForFilename(filename: cellData["poster_path"].string, andQuality: .Low(.Poster)) {
            cell.posterImageView.setImageWith(URLRequest(url: lowFullURL), placeholderImage: nil, success: { [weak self] urlRequest, httpURLResponse, image in
                if let highFullURL = self?.imageURLForFilename(filename: cellData["poster_path"].string, andQuality: .High(.Poster)) {
                    // AFNetworking was not calling any callbacks for the subsequent setImage call if it was triggered immediately. My guess at stepping through it was that it was actually calling the first callback above, again, but I'm not sure. This resolved it.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        cell.posterImageView.setImageWith(highFullURL, placeholderImage: image)
                    }
                }
            }, failure: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
        UIView.animate(withDuration: 0.15, animations: {
            backgroundView.backgroundColor = UIColor.orange.withAlphaComponent(0)
        })
        tableView.cellForRow(at: indexPath)?.selectedBackgroundView = backgroundView
    }
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieList.separatorInset = UIEdgeInsets.zero
        errorLabel.isHidden = true
        
        // Get initial data
        refreshControl.beginRefreshing()
        fetchMovieDataForNextPage()
        
        let loaderFrame = CGRect(x: 0, y: movieList.contentSize.height, width: movieList.bounds.size.width, height: InfiniteScrollLoadingIndicator.defaultHeight)
        infiniteScrollLoadingIndicator.frame = loaderFrame
        infiniteScrollLoadingIndicator.isHidden = true
        movieList.addSubview(infiniteScrollLoadingIndicator)

        refreshControl.addTarget(self, action: #selector(refreshMovieData), for: UIControlEvents.valueChanged)
        movieList.insertSubview(refreshControl, at: 0)
        
        navigationItem.title = "Now Playing"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = movieList.indexPath(for: sender as! UITableViewCell)!
        let itemForDetail = movieData[selectedIndexPath.row]
        let dvc = segue.destination as! MovieDetailViewController
        
        dvc.movieTitle = itemForDetail["title"].string
        dvc.releaseDate = itemForDetail["release_date"].string
        dvc.popularity = itemForDetail["popularity"].double
        dvc.overview = itemForDetail["overview"].string
        dvc.lowBackdropPath = imageURLForFilename(filename: itemForDetail["backdrop_path"].string, andQuality: .Low(.Backdrop))
        dvc.fullBackdropPath = imageURLForFilename(filename: itemForDetail["backdrop_path"].string, andQuality: .High(.Backdrop))
    }
}

