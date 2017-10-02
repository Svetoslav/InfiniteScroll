//
//  InfiniteScrollViewController.swift
//  InfiniteScroll
//
//  Created by Amay Singhal on 10/6/15.
//  Copyright © 2015 ple. All rights reserved.
//

import UIKit

class InfiniteScrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // table view outlet
    @IBOutlet weak var citiesTableView: UITableView!

    // array data that is displayed in the table
    var displayCities: [String]? {
        didSet {
            // since table is just displaying data in displayCities array,
            // I like to set up a property observer to refresh data in table any time this array changes
            citiesTableView?.reloadData()
        }
    }

    // a boolean to determine whether API has more results or not
    var canFetchMoreResults = true

    struct Constants {
        static let FetchThreshold = 5 // a constant to determine when to fetch the results; anytime   difference between current displayed cell and your total results fall below this number you want to fetch the results and reload the table
        static let FetchLimit = 50 // results to fetch in single call
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // setup table
        citiesTableView.delegate = self
        citiesTableView.dataSource = self

        // Do any additional setup after loading the view.
        fetchDataFromIndex(0)
    }

    // MARK: - Table view delegate/datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCities?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: TableViewCells.BasicTableCell.rawValue, for: indexPath)
        cell.textLabel?.text = displayCities?[indexPath.row]
        return cell
    }

    // This is the method that makes it all happen. With this method you can determine if a cell is going to show up in view.
    // You can use this to your advantage by firing off a request when use is almost about to reach to the end of table
    // for example, if you are loading 50 results at a time, then fire off a request IN BACKGROUND (not blocking the main thread)
    // to fetch more results and once the background call returns update your main array and relaod the table.
    // That's it. This is all you need to make infinite scroll work.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (displayCities!.count - indexPath.row) == Constants.FetchThreshold && canFetchMoreResults {
            fetchDataFromIndex(displayCities!.count)
        }
    }

    // MARK: - Internal methods

    // method to fetch more data in background thread (see Data.switch for more details)
    private func fetchDataFromIndex(_ index: Int) {
        NSLog("Fetching data from index: \(index)")
        CaCities.getCitiesFromIndex(index, andCount: Constants.FetchLimit) { (data: [String]?) -> () in
            if let data = data {
                if index == 0 {
                    self.displayCities = data
                } else {
                    self.displayCities?.append(contentsOf: data)
                }
                self.canFetchMoreResults = !(data.count < Constants.FetchLimit)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
