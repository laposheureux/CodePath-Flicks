//
//  MovieListViewController.swift
//  Flicks
//
//  Created by Aaron on 10/16/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var movieList: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListItem", for: indexPath) as! MovieListCell
        
        // add data
        cell.movieTitle.text = "Movie title sample"
        cell.movieDescription.text = "Once there was a cat."
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

