//
//  ReviewViewController.swift
//  MovieList
//
//  Created by Drew Spelman on 4/18/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ReviewViewController: UITableViewController{
    
    var rightButton = UIBarButtonItem()
    
    var addReview: UIButton = {
        let xx = UIButton(frame: CGRect(x:0,y:0,width:40,height:40))
        xx.setImage(UIImage(named: "cross"), for: .normal)
        xx.addTarget(self, action: #selector(addNewReview), for: .touchUpInside)
        return xx
    }()
    
    @objc func addNewReview(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        self.view.backgroundColor = UIColor.blue
        self.tableView.backgroundColor = UIColor.lightGray
        
        navSetup()
    }
    
    func navSetup(){
        navigationItem.backBarButtonItem?.title = "Back"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.title = "Reviews"
        
        rightButton.customView = addReview
        self.navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
