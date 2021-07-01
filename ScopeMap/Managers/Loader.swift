//
//  Loader.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 01/07/2021.
//

import Foundation
import Combine

class Loader<CachedObject>: ObservableObject {
    var isLoading = false
    var url: URL?
    var cancellable: AnyCancellable?
    var cache: Cache<NSURL, CachedObject>?
    
    init(urlString: String, cache: Cache<NSURL, CachedObject>? = nil) {
        self.url = URL(string: urlString)
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    func onStart() {
        isLoading = true
    }
    
    func onFinish() {
        isLoading = false
    }
    
    func cache(_ object: CachedObject?) {
        guard let url = url else { return }
        object.map { cache?[url as NSURL] = $0 }
    }
}
