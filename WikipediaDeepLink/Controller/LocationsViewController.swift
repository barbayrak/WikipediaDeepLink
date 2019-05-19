//
//  ViewController.swift
//  WikipediaDeepLink
//
//  Created by Kaan Baris BAYRAK on 18.05.2019.
//  Copyright © 2019 Kaan Baris Bayrak. All rights reserved.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController {
    
    var tableView : UITableView!
    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupTableView()
        resetSearch()
    }
    
    func setupNavBar(){
        self.title = "Locations"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.definesPresentationContext = true
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Search for places"
        search.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        self.navigationItem.searchController = search
    }
    
    func setupTableView(){
        self.tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        setupConstraints()
    }
    
    func setupConstraints(){
        var tableViewConstraints = [NSLayoutConstraint]()
        tableViewConstraints.append(NSLayoutConstraint(item: self.tableView!, attribute: .top, relatedBy: .equal,
                                                       toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0))
        tableViewConstraints.append(NSLayoutConstraint(item: self.tableView!, attribute: .bottom, relatedBy: .equal,
                                                       toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        tableViewConstraints.append(NSLayoutConstraint(item: self.tableView!, attribute: .left, relatedBy: .equal,
                                              toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0))
        tableViewConstraints.append(NSLayoutConstraint(item: self.tableView!, attribute: .right, relatedBy: .equal,
                                              toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0))
        NSLayoutConstraint.activate(tableViewConstraints)
    }
    
    func requestLocation(text : String){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.navigationItem.searchController?.searchBar.text
        
        let search = MKLocalSearch(request: request)
        search.start { (response, err) in
            if let error = err {
                print(error)
                return
            }
            
            self.locations.removeAll()
            
            for item in response!.mapItems {
                self.locations.append(Location(title: item.name ?? "", subTitle: item.placemark.title ?? "", latitude: item.placemark.coordinate.latitude, longtitude: item.placemark.coordinate.longitude))
            }
            
            self.tableView.reloadData()
        }
    }
    
    func resetSearch(){
        self.locations.removeAll()
        self.locations.append(Location(title: "ABN Ambro", subTitle: "Gustav Mahlerlaan 10 (1082 PP) Amsterdam", latitude: 52.3, longtitude: 4.87))
        self.locations.append(Location(title: "Amsterdam Centraal", subTitle: "Stationsplein, 1012 AB Amsterdam, Netherlands", latitude: 52.37, longtitude: 4.89))
        self.locations.append(Location(title: "The Hague", subTitle: "Den Haag , Netherlands", latitude: 52.06, longtitude: 4.30))
        self.tableView.reloadData()
    }
    
}

extension LocationsViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if(self.navigationItem.searchController?.searchBar.text == ""){
            resetSearch()
        }else{
            requestLocation(text: self.navigationItem.searchController?.searchBar.text ?? "")
        }
    }
    
}

extension LocationsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = "wikipedia://places?lat=\(self.locations[indexPath.row].latitude)&lon=\(self.locations[indexPath.row].longtitude)"
        guard let url = URL(string: urlString) else { return }
        
        if(UIApplication.shared.canOpenURL(url)){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            let alert = UIAlertController(title: "Not Found", message: "No Wikipedia app found on this device. Please check that you have Wikipedia app installed on this device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension LocationsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = self.locations[indexPath.row].title
        cell.detailTextLabel?.text = self.locations[indexPath.row].subTitle
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}

