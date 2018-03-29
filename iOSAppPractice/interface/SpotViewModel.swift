//
//  SpotViewModel.swift
//  iOSAppPractice
//
//  Created by Carter on 2018/3/29.
//  Copyright © 2018年 Carter. All rights reserved.
//

import UIKit

class SpotViewModel: NSObject {
    
    typealias DataUpdatedCallback = ()->()
    
    var manager: ApiManager!
    
    init(manager: ApiManager = ApiManager()) {
        self.manager = manager
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var isLoading = false {
        didSet {
            self.dataUpdated?()
        }
    }
    
    var isCompleteLoading = false
    
    var spots = [Spot]()
    
    var offset: Int {
        return spots.count
    }
    
    var dataUpdated: DataUpdatedCallback?
    var showAlertClosure: (()->())?
    
    func loadNextPage() {
        
        if isLoading || isCompleteLoading {
            return
        }
        
        isLoading = true
        
        self.fetchSpotList(offset: offset) { [weak self] (success, pageSpots, errorMessage) in
            
            guard let strongSelf = self else { return }
            
            if success {
                
                if let p = pageSpots {
                    if p.count != 0 {
                        strongSelf.spots.append(contentsOf: p)
                    }else{
                        strongSelf.isCompleteLoading = true
                    }
                }
                
            }else {
                
                if let e = errorMessage {
                    strongSelf.alertMessage = e
                }
            }
            
            strongSelf.isLoading = false
        }
    }
    
    func fetchSpotList( offset: Int, complete: @escaping ( _ success: Bool, _ results: [Spot]?, _ errorMessage: String? )->() ) {
        
        manager.fetchSpotList(offset: offset) { [weak self] (success, response) in
            if success {
                guard let strongSelf = self else { return }
                
                if let results = strongSelf.jsonToObj(response) {
                    complete( true , results, nil )
                }else {
                    complete( false , nil, "Wrong Return Data Format" )
                }
                
            } else {
                complete( false, nil , response as? String )
            }
        }
    }
    
    func jsonToObj( _ response: Any? ) -> [Spot]? {
        if let response = response as? [AnyHashable: Any],
            let result = response["result"] as? [AnyHashable: Any],
            let results = result["results"] as? [[AnyHashable: Any]] {
            
            var spots = [Spot]()
            results.forEach({ (jsonDic) in
                if let charOBj = Spot.formatter(from: jsonDic) {
                    spots.append(charOBj)
                }
            })
            
            return spots
        }else {
            return nil
        }
    }
}
