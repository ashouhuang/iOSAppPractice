//
//  SpotViewController.swift
//  iOSAppPractice
//
//  Created by Carter on 2018/3/29.
//  Copyright © 2018年 Carter. All rights reserved.
//

import UIKit

class SpotViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    let minHeaderHeight: CGFloat = 44 + UIApplication.shared.statusBarFrame.height;
    let maxHeaderHeight: CGFloat = 100 + 44 + UIApplication.shared.statusBarFrame.height;
    
    var previousScrollOffset: CGFloat = 0;
    
    lazy var viewModel: SpotViewModel = {
        return SpotViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        self.navigationBarTopConstraint.constant = UIApplication.shared.statusBarFrame.height
    }
    
    func initUI() {
        tableView.estimatedRowHeight = 70.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView!.register(UINib(nibName:ReUseIdentifier.spot, bundle:nil),
                            forCellReuseIdentifier:ReUseIdentifier.spot)
    }
    
    func initViewModel() {
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        viewModel.dataUpdated = { [unowned self] () in
            self.handleUpdateUI()
        }
        
        viewModel.loadNextPage()
    }
    
    func handleUpdateUI() {
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
            if self.viewModel.isLoading {
                self.showLoading()
            }else {
                self.hideLoading()
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDataSource
extension SpotViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReUseIdentifier.spot, for: indexPath) as! SpotTableViewCell
        
        let spotModel = viewModel.spots[indexPath.row]
        
        cell.parkNameLabel.text = spotModel.ParkName
        cell.introductionLabel.text = spotModel.Introduction
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SpotViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {

                if scrollView.contentOffset.y > 0 {
                    newHeight = self.minHeaderHeight
                }else {
                    newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
                }
            }
            
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.setScrollPosition(self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
        
        // Load more api data
        let isContentLargerThanScreen = (scrollView.contentSize.height > scrollView.frame.size.height)
        let viewableHeight = isContentLargerThanScreen ? scrollView.frame.size.height : scrollView.contentSize.height
        
        let isAtBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - viewableHeight + 40)
        if isAtBottom && !viewModel.isLoading {
            viewModel.loadNextPage()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight

        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
}

// MARK: - UI
extension SpotViewController {
    
    func showLoading() {
        let loadingFooter = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingFooter.frame.size.height = 50
        loadingFooter.hidesWhenStopped = true
        loadingFooter.startAnimating()
        
        self.tableView.tableFooterView = loadingFooter
    }
    
    func hideLoading() {
        self.tableView.tableFooterView = UIView()
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: AlertConfig.title, message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: AlertConfig.confirm, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
