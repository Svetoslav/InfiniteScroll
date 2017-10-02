//
//  LoadMoreTableCell.swift
//  InfiniteScroll
//
//  Created by Svetoslav on 2/10/17.
//  Copyright © 2017 ple. All rights reserved.
//

import UIKit

class LoadMoreTableCell: UITableViewCell {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?

    func startAnimating() {
        activityIndicator?.startAnimating()
    }

    func stopAnimating() {
        activityIndicator?.stopAnimating()
    }
}
