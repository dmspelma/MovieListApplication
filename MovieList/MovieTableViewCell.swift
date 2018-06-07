//
//  MovieTableViewCell.swift
//  MovieList
//
//  Created by Drew Spelman on 3/22/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Foundation

class MovieTableViewCell: UITableViewCell {
    
    var link: ViewController
    
    let moviePhoto:UIImageView = {
        let mimage = UIImageView()
        mimage.sizeToFit()
        return mimage
    }()
    
    let movieTitle:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


