//
//  SlideMenu.swift
//  MovieList
//
//  Created by Drew Spelman on 4/21/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit

class SlideMenu: NSObject {
    let name: MenuName
    let imageName: String
    
    init(name: MenuName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

enum MenuName: String {
    case MostPopular = "Popular"
    case NowPlaying = "Now Playing"
    case TopRated = "Top Rated"
    case Favorites = "Your Favorites"
    case Cancel = "Cancel"
    case Logout = "Logout"
    
}

class SlideMenuCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
            
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            
            iconImageView.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray
        }
    }
    
    var menu: SlideMenu? {
        didSet {
            nameLabel.text = menu?.name.rawValue
            
            if let imageName = menu?.imageName {
                iconImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = UIColor.darkGray
            }
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Slide Menu"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "menu")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        
        addSubview(nameLabel)
        addSubview(iconImageView)
        
        addConstraintsWithFormat("H:|-8-[v0(30)]-8-[v1]|", views: iconImageView, nameLabel)
        
        addConstraintsWithFormat("V:|[v0]|", views: nameLabel)
        
        addConstraintsWithFormat("V:[v0(30)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
}


class SlideMenuLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let bgView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 60
    
    let menus: [SlideMenu] = {
        return [SlideMenu(name: .MostPopular, imageName: "popular"), SlideMenu(name: .NowPlaying, imageName: "nowplaying"), SlideMenu(name: .TopRated, imageName: "toprated"), SlideMenu(name: .Favorites, imageName: "heart"), SlideMenu(name: .Logout, imageName: "logout"), SlideMenu(name: .Cancel, imageName: "cancel")]
    }()
    
    var homeController: ViewController?
    var xLeftAnchor: Bool?
    
    func showMenus() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            
            bgView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(bgView)
            
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(menus.count) * cellHeight
            let width: CGFloat = window.frame.width * 3/4
            
            var x:CGFloat
            
            if xLeftAnchor! {
                x = 0
            }else {
                x = window.frame.width - width
            }
            
            let y = window.safeAreaInsets.top + 45
            
            collectionView.frame = CGRect(x: window.frame.width, y: window.frame.height, width: width, height: height)
            
            bgView.frame = window.frame
            bgView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.bgView.alpha = 1
                
                self.collectionView.frame = CGRect(x: x, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(menu: SlideMenu?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.bgView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
            
        }) { (completed: Bool) in
//            if menu?.name != .Cancel && menu?.imageName != "" {
//                //self.homeController?.showControllerForSlideMenu(menu!)
//                self.homeController?.logoutFunc()
//            }
            if (menu?.name == .MostPopular) {
                self.homeController?.showControllerForSlideMenu(menu!, xNum: 1)
            }
            else if (menu?.name == .NowPlaying){
                self.homeController?.showControllerForSlideMenu(menu!, xNum: 2)
            }
            else if (menu?.name == .TopRated){
                self.homeController?.showControllerForSlideMenu(menu!, xNum: 3)
            }
            else if (menu?.name == .Favorites){
                self.homeController?.showControllerForSlideMenu(menu!, xNum: 4)
            }
            else if (menu?.name == .Logout){
                self.homeController?.showControllerForSlideMenu(menu!, xNum: 5)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SlideMenuCell
        
        let menu = menus[indexPath.item]
        cell.menu = menu
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let menu = self.menus[indexPath.item]
        handleDismiss(menu: menu)
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(SlideMenuCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
