//
//  ViewController.swift
//  MovieList
//
//  Created by Drew Spelman on 3/22/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

var gid: Int?
var pulledId = ""
var favstorage: [String]?

class ViewController: UITableViewController {
    
    let favImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "unheart")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var loginViewController = UIViewController()
    var username: String?
    var fullname: String?
    var location: String?
    var profileurl: String?
    var menuIsVisible = false
    var leftMenuButton = UIBarButtonItem()
    var topname: String?
    
    var gid: Int?

    weak var leadingC: NSLayoutConstraint!
    weak var trailingC: NSLayoutConstraint!
    
    //default will be popular movies
    var url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=2fd407ce058f68122374ef80f3e35200")
    var results: MovieResults?
    var favResults: MovieInfo?
    var favOn = false
    var moviePicUrl = "http://image.tmdb.org/t/p/w92/"
    var num = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginViewController.dismiss(animated: true, completion: nil)
        
        downloadJSON {
            print("JSON download successful")
            self.tableView.reloadData()
        }
        //navigationItem.title = "Popular Movies"
        
        
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "cellid")
        self.view.backgroundColor = UIColor.blue
        self.tableView.backgroundColor = UIColor.lightGray
        fetchUserProfile()
    }

    
    
    func showControllerForSlideMenu(_ menu: SlideMenu, xNum: Int) {
        if (xNum == 1){
//            let dummyViewController = ViewController()
//            navigationController?.pushViewController(dummyViewController, animated: true)
            
            url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=2fd407ce058f68122374ef80f3e35200")
            downloadJSON {
                print("JSON download successful")
                self.tableView.reloadData()
            }
            if (topname == nil){
                
            }
            else {
                self.navigationItem.title = topname! + " | Most Popular"
            }
        }
        else if (xNum == 2){
//            let dummyViewController = NowPlayingViewController()
//            navigationController?.pushViewController(dummyViewController, animated: true)
            
            url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=2fd407ce058f68122374ef80f3e35200")
            downloadJSON {
                print("JSON download successful")
                self.tableView.reloadData()
            }
            if (topname == nil){
            }
            else {
                self.navigationItem.title = topname! + " | Now Playing"
            }
        }
        else if (xNum == 3){
//            let dummyViewController = TopRatedViewController()
//            navigationController?.pushViewController(dummyViewController, animated: true)
            
            url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=2fd407ce058f68122374ef80f3e35200")
            //url = URL(string: "https://api.themoviedb.org/3/movie/447332?api_key=2fd407ce058f68122374ef80f3e35200")
            downloadJSON {
                print("JSON download successful")
                self.tableView.reloadData()
            }
            if (topname == nil){
                
            }
            else {
                self.navigationItem.title = topname! + " | Top Rated"
            }
        }
        else if (xNum == 4){
            //let dummyViewController = FavoritesViewController()
            if (topname == nil){
            }
            else {
                favOn = true
                self.navigationItem.title = topname! + " | My Favorites"
                self.tableView.reloadData()
                guard let uid = Auth.auth().currentUser?.uid else {
                    //for some reason uid = nil
                    return
                }
                self.results?.movies.removeAll()
                Database.database().reference().child("users").child(uid).child("FavoriteMovies").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("In favorites")
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        pulledId = snap.key
                        favstorage?.append(pulledId)
                        self.favoritesPull {
                            print("FAVORITES download successful")
                            //self.tableView.reloadData()
                            print("Calling ReloadData:")
                            self.tableView.reloadData()
                            //print(self.favResults)
                            
                        }
                        
                        //favoritesPull()
                        //print("key = \(key)")
                    }
                    //self.favOn = false
                    //print(self.favResults)
                    //print("1")
                }, withCancel: nil)
                
            }
            //self.favOn = false
            //navigationController?.pushViewController(dummyViewController, animated: true)
        }
        else {
            logoutFunc()
        }
    }
    
    func navSetup(user: User){
        navigationItem.backBarButtonItem?.title = "Logout"
        navigationController?.navigationBar.barTintColor = UIColor.white
        if let pname = user.username{
            navigationItem.title = pname  + " | Most Popular"
            if topname == nil {
                topname = pname
            }
        }
        //navigationItem.title = username
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(editProfile))
        let menuLeftButton = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLeftMenu))
        navigationItem.leftBarButtonItem = menuLeftButton
        //leftMenuButton.customView = funcMenuButton
        //navigationItem.leftBarButtonItem = leftMenuButton
    }
    
    @objc func handleLeftMenu() {
        //show menu
        slideMenuLauncherLeft.showMenus()
    }
    
    lazy var slideMenuLauncherLeft: SlideMenuLauncher = {
        let launcher = SlideMenuLauncher()
        launcher.homeController = self
        launcher.xLeftAnchor = true
        return launcher
    }()
    
    
    @objc func logoutFunc(){
        do {
            try Auth.auth().signOut()
            let loginController = LoginViewController()
            self.navigationController?.pushViewController(loginController, animated: true)
        } catch let err {
            print(err)
        }
    }
    
    @objc func editProfile(){
        let profileController = ProfileController()
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            print("This is ViewController")
            return
        }
        // Read User information from DB
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                //[String : AnyObject]
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary)
                self.navSetup(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func favoritesPull(completed: @escaping () -> () ) {
        //        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=2fd407ce058f68122374ef80f3e35200")
        print(pulledId)
        let x = "https://api.themoviedb.org/3/movie/" + pulledId + "?api_key=2fd407ce058f68122374ef80f3e35200"
        print(x)
        let url = URL(string: x)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check downloaded JSON data
                guard let jsondata = data else { return }
                do {
                    self.favResults = try JSONDecoder().decode(MovieInfo.self, from: jsondata)
                    self.results?.movies.append(self.favResults!)
                    DispatchQueue.main.async {
                        completed()
                    }
                }catch {
                    print("JSON Downloading Error!")
                }
            }
            }.resume()
    }
    
    func downloadJSON(completed: @escaping () -> () ) {
//        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=2fd407ce058f68122374ef80f3e35200")
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check downloaded JSON data
                guard let jsondata = data else { return }
                do {
                    print("\n DownloadJsonFuncHere \n")
                    self.results = try JSONDecoder().decode(MovieResults.self, from: jsondata)
                    
                    DispatchQueue.main.async {
                        completed()
                    }
                }catch {
                        print("JSON Downloading Error!")
                    }
                }
            }.resume()
        }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! ToDoCell
        //cell.link = self
//        print(favOn)
//        if favOn == true {
//            cell.backgroundColor = UIColor.cyan
//
//            cell.textLabel?.text = self.favResults?.title
//            cell.detailTextLabel?.text = "0"
//            print("\n" + (cell.textLabel?.text)! + "\n")
//            let url = "https://image.tmdb.org/t/p/w92"
//
//            if favResults == nil{
//            }
//            else{
//                let downloadMoviePosterURL = URL(string: url + (self.favResults?.posterPath)!)!
//                print (downloadMoviePosterURL)
//                let moviePosterData = NSData(contentsOf: downloadMoviePosterURL as URL)
//                let posterPic = UIImage(data: moviePosterData! as Data)
//                cell.imageView?.image = posterPic
//            }
//        }
        if (indexPath.row < self.results!.movies.count){

            cell.backgroundColor = UIColor.cyan

            print("Setting Up Table")
            cell.textLabel?.text = self.results?.movies[indexPath.row].title
            cell.detailTextLabel?.text = "0"
            //cell.favButton.setImage(UIImage(named: "unheart"), for: .normal)
            cell.favButton.tag = indexPath.row
            cell.theGid = self.results?.movies[indexPath.row].id
            gid = self.results?.movies[indexPath.row].id
            cell.theTitle = self.results?.movies[indexPath.row].title
            //cell.favButton.addTarget(self, action: #selector(ToDoCell.handleFav), for: .touchUpInside)
       
            let url = "https://image.tmdb.org/t/p/w92"

            if results == nil{
            }
            else{
                let downloadMoviePosterURL = URL(string: url + (self.results?.movies[indexPath.row].posterPath)!)!
                print (downloadMoviePosterURL)
                let moviePosterData = NSData(contentsOf: downloadMoviePosterURL as URL)
                let posterPic = UIImage(data: moviePosterData! as Data)
                cell.imageView?.image = posterPic
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = results?.movies.count {
            return num
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let movie = results?.movies[indexPath.row] {
                self.showDetailOfMovie(movie: movie)
            }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            results?.movies.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func showDetailOfMovie(movie: MovieInfo){
            let detailController = DetailedViewController()
            detailController.movie = movie
            navigationItem.backBarButtonItem?.title = "Cancel"
            navigationController?.pushViewController(detailController, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


class ToDoCell: UITableViewCell {
    var fav = false
    var theTitle: String?
    var thePoster: String?
    var theGid: Int?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 54, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 54, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let favButton: UIButton = {
        let iv = UIButton()
        //iv.image = UIImage(named: "unheart")
        iv.setImage(UIImage(named: "unheart"), for: .normal)
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

                func fetchFav() {
                    guard let uid = Auth.auth().currentUser?.uid else {
                        //for some reason uid = nil
                        return
                    }
    
                    //Read Fav and setup fav button for user:
                    Database.database().reference().child("users").child(uid).child("FavoriteMovies").observeSingleEvent(of: .value, with: {(snapshot) in
                        for child in snapshot.children{
                            let snap = child as! DataSnapshot
                            let key = snap.key
                            //If true then user has favorited this movie
                            if (key == "\(self.theGid!)"){
                                self.fav = true
                                self.favButton.setImage(UIImage(named: "heart"), for: .normal)
                            }
//                            else {
//                                self.favButton.setImage(UIImage(named: "unheart"), for: .normal)
//                            }
                        }
                    }, withCancel: nil)
                }
    
    @objc func handleFav(_ sender: UIButton){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        if (fav == false){
            fav = true
            favButton.setImage(UIImage(named: "heart"), for: .normal)
            let ref = Database.database().reference()
            let favReference = ref.child("users").child(uid).child("FavoriteMovies").child("\(theGid!)")
            let values = ["movieID": theGid as Any, "fav": fav, "title": theTitle as Any] as [String : AnyObject]
            favReference.updateChildValues(values, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
        }
            //going from fav -> not fav
        else {
            fav = false
            favButton.setImage(UIImage(named: "unheart"), for: .normal)
            let ref = Database.database().reference()
            ref.child("users").child(uid).child("FavoriteMovies").child("\(theGid!)").removeValue()
        }
    }
    
    override func prepareForReuse() {
        self.favButton.setImage(UIImage(named: "unheart"), for: .normal)
        self.fav = false
        fetchFav()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(favButton)
        
        
        favButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        favButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        favButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        favButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        favButton.addTarget(self, action: #selector(handleFav), for: .touchUpInside)
        fetchFav()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
