//
//  ImageLoader.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 27/06/2021.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class ImageLoader: Loader<UIImage> {
    @Published var image: UIImage?

    private static let processingQueue = DispatchQueue(label: "image-processing")
    
    init(url: String, cache: Cache<NSURL, UIImage>? = nil) {
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        super.init(urlString: urlString, cache: cache)
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading, let url = url else { return }
        
        if let image = cache?[url as NSURL] {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.processingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

}
