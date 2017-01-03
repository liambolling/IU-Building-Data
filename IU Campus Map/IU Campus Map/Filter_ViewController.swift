//
//  Filter_ViewController.swift
//  IU Campus Map
//
//  Created by Liam Bolling on 11/13/16.
//
//

import Foundation
import UIKit
import CoreData

class Filter_View: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        print("nah")
    }

    var tableView: UITableView = UITableView()
    var viewController: AnyObject? = nil
    
    var items: [String] = ["Viper", "X", "Games"]
    var shouldShowSearchResults: Bool = false
    var searchController: UISearchController!
    
    var mapData: [AnyObject] = []
    var filteredMapData: [AnyObject] = []
    
    
    init(frame: CGRect, viewController: ViewController) {
        super.init(frame: frame)
        
        self.viewController = viewController
        
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        backgroundView.backgroundColor = UIColor.white
        backgroundView.layer.cornerRadius = 5.0
        backgroundView.layer.borderWidth = 1.0
        backgroundView.layer.borderColor = UIColor.clear.cgColor
        backgroundView.layer.masksToBounds = true
        
        backgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        backgroundView.layer.shadowRadius = 2.0
        backgroundView.layer.shadowOpacity = 1.0
        backgroundView.layer.masksToBounds = false
        self.addSubview(backgroundView)
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        tableView.layer.cornerRadius = 5.0
        tableView.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.addSubview(tableView)
        
    }
    
    func addTableData(mapData: NSArray) {
        self.mapData = mapData as [AnyObject]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setFilteredMapData(filteredArray: NSArray) {
        mapData = filteredArray as [AnyObject]
        self.tableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = (mapData[indexPath.row] as! NSManagedObject).value(forKey: "name") as! String?
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (self.viewController as! ViewController).fromFilterToMap(object: mapData[indexPath.row] as! NSManagedObject)
    }
    
    
}
