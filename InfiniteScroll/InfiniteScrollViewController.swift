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

    // this governs the presentation of "loading" activity cell
    private var isLoading: Bool = false

    struct Constants {
        static let FetchThreshold = 1 // a constant to determine when to fetch the results; anytime   difference between current displayed cell and your total results fall below this number you want to fetch the results and reload the table
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
        return displayCities?.count ?? 0
        case 1: // section 1 is the "loading" view section
            return 1
        default:
            return 0
    }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if (indexPath.section == 1) {
            cell = citiesTableView.dequeueReusableCell(withIdentifier: TableViewCells.LoadMoreTableCell.rawValue, for: indexPath)
            (cell as? LoadMoreTableCell)?.startAnimating()
        }
        else {
            cell = citiesTableView.dequeueReusableCell(withIdentifier: TableViewCells.BasicTableCell.rawValue, for: indexPath)
        cell.textLabel?.text = displayCities?[indexPath.row]
        }

        return cell
    }

    // This is the method that makes it all happen. With this method you can determine if a cell is going to show up in view.
    // You can use this to your advantage by firing off a request when use is almost about to reach to the end of table
    // for example, if you are loading 50 results at a time, then fire off a request IN BACKGROUND (not blocking the main thread)
    // to fetch more results and once the background call returns update your main array and relaod the table.
    // That's it. This is all you need to make infinite scroll work.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (displayCities != nil &&
            (displayCities!.count - indexPath.row) == Constants.FetchThreshold &&
            canFetchMoreResults &&
            !isLoading) {

            // the dispatch is needed because presenting the "loading" cell from within the willDisplay
            // call stack gets the table view in an inconsistent state and an excetion is thrown
            DispatchQueue.main.async {
                self.fetchDataFromIndex(self.displayCities!.count)
            }
        }
    }

    // MARK: - Internal methods

    // method to fetch more data in background thread (see Data.switch for more details)
    private func fetchDataFromIndex(_ index: Int) {
        NSLog("Fetching data from index: \(index)")

        isLoading = true
        citiesTableView.insertSections([1], with: .bottom)

        CaCities.getCitiesFromIndex(index, andCount: Constants.FetchLimit) { (data: [String]?) -> () in
            self.isLoading = false
            self.citiesTableView.deleteSections([1], with: .top)

            if let data = data {
                // major hackity-sax warning: the delayed dispatch is because
                // setting `displayCities` triggers a reload of the table view,
                // which interrupts the `deleteSections` animation and things
                // get visually plenty glitchy. unfortunately `CATransaction.animationDuration()`
                // doesn't return reasonable value outside the actual animation block and I have
                // to resort to magic number (of half a second in this case)
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + 0.5) {
                        if index == 0 {
                            self.displayCities = data
                        } else {
                            self.displayCities?.append(contentsOf: data)
                        }
                        self.canFetchMoreResults = !(data.count < Constants.FetchLimit)
                }
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
