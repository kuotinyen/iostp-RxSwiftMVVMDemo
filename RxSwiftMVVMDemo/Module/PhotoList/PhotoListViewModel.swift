//
//  PhotoListViewModel.swift
//  MVVMPlayground
//
//  Created by Neo on 03/10/2017.
//  Copyright © 2017 ST.Huang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoListViewModel {
    
    let apiService: APIServiceProtocol
    
    var photos: Observable<[Photo]> { return photosRelay.asObservable() }
    private let photosRelay: BehaviorRelay<[Photo]> = BehaviorRelay(value: [])
    
    var cellViewModels: Observable<[PhotoListCellViewModel]> { return cellViewModelsRelay.asObservable() }
    private let cellViewModelsRelay: BehaviorRelay<[PhotoListCellViewModel]> = BehaviorRelay(value: [])
    
    var isFetchingPhotos: Observable<Bool> { return isFetchingPhotosRelay.asObservable() }
    private let isFetchingPhotosRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var userPressedPhoto: Observable<PressPhotoResult> { return userPressedPhotoSubject.asObservable() }
    private let userPressedPhotoSubject: PublishSubject<PressPhotoResult> = PublishSubject()
    
    let bag = DisposeBag()
    
    var numberOfCells: Int {
        return cellViewModelsRelay.value.count
    }
    
    init( apiService: APIServiceProtocol ) {
        self.apiService = apiService
        
        photos
            .map { photos -> [PhotoListCellViewModel] in
                photos.map { self.createCellViewModel(photo: $0) }
            }
            .bind(to: cellViewModelsRelay)
            .disposed(by: bag)
    }
    
    func viewIsReady() {
        
        isFetchingPhotosRelay.accept(true)
        apiService.fetchPopularPhoto { [weak self] (success, photos, error) in
            self?.photosRelay.accept(photos)
            self?.isFetchingPhotosRelay.accept(false)
        }
    }
    
}

enum PhotoError: Error {
    case userPressedNotSaleError
}

enum PressPhotoResult {
    case photo(Photo)
    case error(PhotoError)
}

extension PhotoListViewModel {
    
    func userPressed(at indexPath: IndexPath) {
        let photo = self.photosRelay.value[indexPath.row]
        
        let result = photo.for_sale ?
            PressPhotoResult.photo(photo) :
            PressPhotoResult.error(PhotoError.userPressedNotSaleError)
        
        userPressedPhotoSubject.onNext(result)
    }
}

extension PhotoListViewModel {
    
    func getCellViewModel( at indexPath: IndexPath ) -> PhotoListCellViewModel {
        return cellViewModelsRelay.value[indexPath.row]
    }
    
    func createCellViewModel( photo: Photo ) -> PhotoListCellViewModel {
        
        //Wrap a description
        var descTextContainer: [String] = [String]()
        if let camera = photo.camera {
            descTextContainer.append(camera)
        }
        if let description = photo.description {
            descTextContainer.append( description )
        }
        let desc = descTextContainer.joined(separator: " - ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return PhotoListCellViewModel( titleText: photo.name,
                                       descText: desc,
                                       imageUrl: photo.image_url,
                                       dateText: dateFormatter.string(from: photo.created_at) )
    }
}

struct PhotoListCellViewModel {
    let titleText: String
    let descText: String
    let imageUrl: String
    let dateText: String
}
