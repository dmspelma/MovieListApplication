//
//  DetailedViewController.swift
//  MovieList
//
//  Created by Drew Spelman on 3/22/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DetailedViewController: UIViewController{
    
    var movieDetail: MovieData?
    var movieTitle = UILabel(frame: CGRect(x:0, y:0, width:400, height:21))
    var scoreLabel = UILabel(frame: CGRect(x:0, y:0, width:400, height:20))
    var aboutMovie = UITextView(frame: CGRect(x:0, y:0, width: 400, height:200))
    var movieRelease = UILabel(frame: CGRect(x:0, y:0, width:400, height:25))
    var rating = UILabel(frame: CGRect(x:0, y:0, width: 400, height: 25))
    var posterImageview = UIImageView(frame: CGRect(x:0, y:0, width:400, height:250))
    var movieGenres = UILabel(frame: CGRect(x:0, y:0, width:400, height:25))
    var leftstar = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    var midleftstar = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    var midstar = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    var midrightstar = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    var rightstar = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    
    //Stuff for DB
    var likeNum = 0
    var scoreNum = 0
    
    
    let thumbsUp: UIButton = {
        let xx = UIButton(frame: CGRect(x:0,y:0,width:40,height:40))
        //xx.backgroundColor = UIColor.white
        xx.setImage(UIImage(named: "thumbup"), for: .normal)
        xx.translatesAutoresizingMaskIntoConstraints = false
        //xx.layer.cornerRadius = 5
        //xx.layer.masksToBounds = true
        //xx.setTitle("Login", for: UIControlState.normal)
        //xx.setTitleColor(UIColor.blue, for: UIControlState.normal)
        //xx.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        xx.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return xx
    }()
    
    let thumbsDown: UIButton = {
        let xx = UIButton(frame: CGRect(x:0,y:0,width:40,height:40))
        xx.setImage(UIImage(named: "thumbdown"), for: .normal)
        xx.translatesAutoresizingMaskIntoConstraints = false
        xx.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        return xx
    }()
    
    var gid: Int?
    var mtitle: String?
    
    //var thumbsUp = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    //var thumbsDown = UIImageView(frame: CGRect(x:0,y:0,width:40,height:40))
    var postertext = "https://image.tmdb.org/t/p/w342"
    
    var movie: MovieInfo?{
        didSet{
            let id = movie?.id
            gid = movie?.id
            mtitle = movie?.title
            let link = "https://api.themoviedb.org/3/movie/\(id!)?api_key=2fd407ce058f68122374ef80f3e35200"
            print(link)
            let url = URL(string: link)
            URLSession.shared.dataTask(with: url!){ (data, response, err) in
                if err == nil {
                    // check downloaded JSON data
                    guard let jsondata = data else { return }
                    do {
                        self.movieDetail = try JSONDecoder().decode(MovieData.self, from: jsondata)
                        DispatchQueue.main.async {
                            self.setupViews()
                        }
                        print("JSON successfully downloaded")
                    }catch {
                        print("JSON Downloading Error!")
                    }
                }
                }.resume()
        }
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        // Read User's likes information from DB
        Database.database().reference().child("users").child(uid).child("LikedMovies").child("\(String(describing: gid))").observeSingleEvent(of: .value, with: { (snapshot) in
            print("yes")
            if let dictionary = snapshot.value as? [String : AnyObject] {
                //[String : AnyObject]
                //                self.navigationItem.title = dictionary["name"] as? String

                let liked = LikedMovies(dictionary: dictionary)
                
                if (liked.like == nil){
                    print("like value is null")
                }
                else{
                    self.likeNum = liked.like!
                    print("LikeNum value: " + "\(self.likeNum)")
                    if (self.likeNum > 0){
                        self.thumbsUp.setImage(UIImage(named: "clickup"), for: .normal)
                    }
                    else if (self.likeNum < 0){
                        self.thumbsDown.setImage(UIImage(named: "clickdown"), for: .normal)
                    }
                    //self.setupProfileWithUser(user: user)
                }
            }

        }, withCancel: nil)
        
        //Read Movie information from DB
        Database.database().reference().child("movies").child("\(String(describing: gid))").observeSingleEvent(of: .value, with: { (snapshot) in
            print("yes")
            if let dictionary = snapshot.value as? [String : AnyObject] {
                //[String : AnyObject]
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let moviesave = MovieSave(dictionary: dictionary)
                if (moviesave.score == nil){
                    print("There is no movie score info")
                    self.scoreLabel.text = "Number of users who like this movie: " + "\(self.scoreNum)"
                }
                else{
                    self.scoreNum = moviesave.score!
                    print("ScoreNum value: " + "\(self.scoreNum)")
                    self.scoreLabel.text = "Number of users who like this movie: " + "\(self.scoreNum)"
                    //self.setupProfileWithUser(user: user)
                }
            }
            
        }, withCancel: nil)
    }
    
    @objc func handleLike(sender: UIButton){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        if (likeNum <= 0){
            likeNum = 1
            scoreNum = scoreNum + 1
            
            let ref = Database.database().reference()
            let usersReference = ref.child("users").child(uid).child("LikedMovies").child("\(String(describing: gid))")
            let values1 = ["movieId": gid, "like": likeNum] as [String : AnyObject]
            let movieReference = ref.child("movies").child("\(String(describing: gid))")
            let values2 = ["title": movieTitle.text as Any, "score": (scoreNum)] as [String : AnyObject]
            movieReference.updateChildValues(values2, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
            usersReference.updateChildValues(values1, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
            thumbsUp.setImage(UIImage(named: "clickup"), for: .normal)
            thumbsDown.setImage(UIImage(named: "thumbdown"), for: .normal)
            scoreLabel.text = "Number of users who like this movie: " + "\(scoreNum)"
        }
    }
    
    @objc func handleDislike(sender: UIButton){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        if (likeNum >= 0){
            likeNum = -1
            scoreNum = scoreNum - 1
            
            let ref = Database.database().reference()
            let usersReference = ref.child("users").child(uid).child("LikedMovies").child("\(String(describing: gid))")
            let values1 = ["movieId": gid, "like": likeNum] as [String : AnyObject]
            let movieReference = ref.child("movies").child("\(String(describing: gid))")
            let values2 = ["title": movieTitle.text as Any, "score": (scoreNum)] as [String : AnyObject]
            movieReference.updateChildValues(values2, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
            usersReference.updateChildValues(values1, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
            
            thumbsDown.setImage(UIImage(named: "clickdown"), for: .normal)
            thumbsUp.setImage(UIImage(named: "thumbup"), for: .normal)
            scoreLabel.text = "Number of users who like this movie: " + "\(scoreNum)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scoreLabel.text = "Number of users who like this movie: " + "\(scoreNum)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reviews", style: .plain, target: self, action: #selector(reviewCont))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(returnTo))
        
        self.view.backgroundColor = UIColor.lightGray
        movieTitle.text = movieDetail?.the_title!
        //print(movieTitle.text)
        movieTitle.center = CGPoint(x: 200, y: 90)
        movieTitle.font = UIFont.boldSystemFont(ofSize: 22)
        movieTitle.textAlignment = .left
        
        
        posterImageview.translatesAutoresizingMaskIntoConstraints = false
        posterImageview.center = CGPoint(x:200, y:240)
        
        if movieDetail == nil{
        }
        else {
            postertext += (movieDetail?.backdrop!)!
        
        let downloadBackdropURL = URL(string: postertext)!
        let movieBackDrop = NSData(contentsOf: downloadBackdropURL as URL)
        let backPic = UIImage(data: movieBackDrop! as Data)
        
        posterImageview.image = backPic!
        }
//        var constraints = [NSLayoutConstraint]()
//        constraints.append(NSLayoutConstraint(item: posterImageview, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
//        constraints.append(NSLayoutConstraint(item: posterImageview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 0.0))
//        constraints.append(NSLayoutConstraint(item: posterImageview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 250.0))
//        NSLayoutConstraint.activate(constraints)
        
        aboutMovie.text = movieDetail?.overview!
        aboutMovie.center = CGPoint(x:200, y:470)
        aboutMovie.textAlignment = .left
        aboutMovie.backgroundColor = UIColor.clear
        aboutMovie.font = UIFont.systemFont(ofSize: 16)
        
        if movieDetail == nil{
        }
        else {
            movieRelease.text = "Release Date: " + (movieDetail?.releaseDate!)!
        }
        movieRelease.center = CGPoint(x:200, y:585)
        movieRelease.font = UIFont.boldSystemFont(ofSize: 16)
        movieRelease.textAlignment = .left
        //print(movieRelease.text)
        
        movieGenres.center = CGPoint(x:200, y:605)
        movieGenres.textAlignment = .left
        genresSet()
        
        thumbsUp.center = CGPoint(x:80, y:650)
        leftstar.center = CGPoint(x:120, y:650)
        leftstar.image = UIImage(named: "nostar.png")
        midleftstar.center = CGPoint(x:160, y:650)
        midleftstar.image = UIImage(named: "nostar.png")
        midstar.center = CGPoint(x:200, y:650)
        midstar.image = UIImage(named: "nostar.png")
        midrightstar.center = CGPoint(x:240, y:650)
        midrightstar.image = UIImage(named: "nostar.png")
        rightstar.center = CGPoint(x:280, y:650)
        rightstar.image = UIImage(named: "nostar.png")
        thumbsDown.center = CGPoint(x:320, y:650)
        
        scoreLabel.center = CGPoint(x:240,y:700)
        scoreLabel.textAlignment = .left
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        setRating()
        fetchUserProfile()

        
        //Add all views for view:
        self.view.addSubview(posterImageview)
        self.view.addSubview(aboutMovie)
        self.view.addSubview(movieTitle)
        self.view.addSubview(movieRelease)
        self.view.addSubview(rating)
        self.view.addSubview(movieGenres)
        self.view.addSubview(leftstar)
        self.view.addSubview(midleftstar)
        self.view.addSubview(midstar)
        self.view.addSubview(midrightstar)
        self.view.addSubview(rightstar)
        self.view.addSubview(thumbsUp)
        self.view.addSubview(thumbsDown)
        self.view.addSubview(scoreLabel)
        //Causes errors atm
        //movieTitle.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //movieTitle.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //movieTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        //movieTitle.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        //movieTitle.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reviewCont(){
        let reviewController = ReviewViewController()
        self.navigationController?.pushViewController(reviewController, animated: true)
    }
    
    @objc func returnTo(){
        dismiss(animated: true, completion: nil)
    }
    
    func setupViews(){
        
    }
    
    func genresSet(){
        var textPost = ""
        var counter = 0
        if (movieDetail == nil){
        }
        else {
            for _ in (movieDetail?.genres)!{
                //print(movieDetail?.genres[counter].name)
                textPost = textPost + (movieDetail?.genres[counter].name!)! + ", "
                counter+=1
                
            }
        }
        movieGenres.text = textPost
    }
    
    func setRating(){
        if movieDetail == nil{
            
        }
        else{
            //var movieRating = movieDetail!.rating
            if let movieRating = movieDetail?.rating!, movieRating < 2.0 {
                leftstar.image = UIImage(named: "halfstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 3.0 {
                leftstar.image = UIImage(named: "fullstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 4.0 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "halfstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 5.0 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 5.5 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
                midstar.image = UIImage(named: "halfstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 6.0 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
                midstar.image = UIImage(named: "fullstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 6.5 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
                midstar.image = UIImage(named: "fullstar.png")
                midrightstar.image = UIImage(named: "halfstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 7.0 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
                midstar.image = UIImage(named: "fullstar.png")
                midrightstar.image = UIImage(named: "fullstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 7.5 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
                midstar.image = UIImage(named: "fullstar.png")
                midrightstar.image = UIImage(named: "fullstar.png")
                rightstar.image = UIImage(named: "halfstar.png")
            }
            else if let movieRating = movieDetail?.rating!, movieRating < 8.0 {
                leftstar.image = UIImage(named: "fullstar.png")
                midleftstar.image = UIImage(named: "fullstar.png")
                midstar.image = UIImage(named: "fullstar.png")
                midrightstar.image = UIImage(named: "fullstar.png")
                rightstar.image = UIImage(named: "fullstar.png")
            }
        }
        
    }
    
}
