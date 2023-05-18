//
//  ShoeViewPresenter.swift
//  IlymaxShop
//
//  Created by Максим Тарасов on 18.04.2023.
//

import FirebaseAuth
import UIKit

class ShoeViewPresenter {
    weak var view: ShoeViewController?
    private let shoeViewService = ShoeViewService()
    var product: Shoes?
    var sellerName = ""
    public var pushReview: ([IlymaxReview], String) -> Void = {_,_  in }
    
    var reviews: [IlymaxReview] = []
    var average: Double = 0
    
    
    func loadReviews() {
        shoeViewService.getReviewsByShoesId((product?.id)!) {[weak self] result in
            switch result {
                case .success(let reviews):
                self?.reviews =  reviews
                if reviews.count != 0 {
                    let totalRate = reviews.reduce(0, { $0 + $1.rate })
                    self?.average = (Double(totalRate) / Double(reviews.count) * 100).rounded(.toNearestOrEven) / 100
                }
            case .failure(let error):
                print(error )
            }
        }
        
        shoeViewService.getUser(userID: (product?.ownerId)!) { [weak self] user in
            guard let self = self else { return }
            
            self.sellerName = user?.name ?? ""
            
            DispatchQueue.main.async { [weak self] in
                self?.view?.setupUI()
                self?.view?.hideLoader()
            }
        }
    }
    
    func pushReviews() {
        pushReview(reviews, (product?.id)!)
    }
    
    func addToCart(cartItem: IlymaxCartItem) {
        shoeViewService.addItemToCart(userID: FirebaseAuth.Auth.auth().currentUser!.uid, item: cartItem)
    }
    
}
