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
    
    lazy var viewModel: SpotViewModel = {
        return SpotViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initViewModel()
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let isContentLargerThanScreen = (scrollView.contentSize.height > scrollView.frame.size.height)
        let viewableHeight = isContentLargerThanScreen ? scrollView.frame.size.height : scrollView.contentSize.height
        
        let isAtBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - viewableHeight + 40)
        if isAtBottom && !viewModel.isLoading {
            viewModel.loadNextPage()
        }
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
