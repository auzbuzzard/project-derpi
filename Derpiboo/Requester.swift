//
//  Server.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit
import Fuzi

class Requester {
    static var base_url: String {
        return "https://derpibooru.org"
    }
}

class ListRequester: Requester {
    enum ListType {
        case images, lists, search
    }
    
    static func url(for type: ListType) -> String {
        switch type {
        case .images: return base_url + "/images.json"
        case .lists: return base_url + "/lists.json"
        case .search: return base_url + "/search.json"
        }
    }
    
    func downloadList(for type: ListType, tags: [String]?, page: Int?) -> Promise<ListResult> {
        var params = [String]()
        
        if let page = page {
            params.append("page=\(page)")
        }
        
        if let tags = tags {
            params.append("q=\(tags.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)")
        }
        #if DEBUG
            if UserDefaults.standard.bool(forKey: Preferences.useE621Mode.rawValue) {
                params.append("filter_id=56027")
            }
        #endif
        
        let url = ListRequester.url(for: type) + "?\(params.joined(separator: "&"))"
        
        #if DEBUG
            print("ListRequester downloading list: \(url)")
        #endif
        
        let network = Network.get(url: url)
        
        return network.then(on: .global(qos: .userInitiated)) { data -> Promise<ListResult> in
            return ListParser.parse(data: data, as: type)
        }
    }
    
}

class ImageRequester: Requester {
    static var image_url: String { return base_url }
    
    func getUrl(for id: Int, withJson: Bool = true) -> String {
        return ImageRequester.image_url + "/\(id)\(withJson ? "" : ".json")"
    }
    func downloadImageResult(for id: Int) -> Promise<ImageResult> {
        let url = getUrl(for: id)
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<ImageResult> in
            return ImageParser.parse(data: data)
        }
    }
    
}

class TagRequester: Requester {
    static var tag_url: String { return base_url + "/tags" }
    
    func downloadTag(for id: Int) -> Promise<TagResult> {
        let url = TagRequester.tag_url + "\(id).json"
        
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<TagResult> in
            return TagParser.parse(data: data)
        }
    }
    @available(*, unavailable, message: "DB don't have a way to return tag search in json yet.")
    func searchTag(searchTerm: String) -> Promise<TagResult> {
        let url = TagRequester.tag_url + "?tq=\(searchTerm).json"
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<TagResult> in
            return TagParser.parse(data: data)
        }
    }
}
/*
class UserRequester: Requester {
    static let user_url = base_url + "/user/index"
    static let user_show_url = base_url + "/user/show"
    
    func getUser(for id: Int, completion: @escaping completion) {
        let url = UserRequester.user_show_url + "/\(id).json"
        do {
            try Network.fetch(url: url, params: nil) { data in
                DispatchQueue.global().async {
                    do {
                        let result = try UserParser.parse(data: data)
                        completion(result)
                    } catch {
                        print("UserRequester get error: \(data) of url: \(url)")
                    }
                }
            }
        } catch {
            print("UserRequester Error")
        }
    }
    
    func get(userOfId id: Int, searchCache: Bool, completion: @escaping completion) {
        if searchCache, let user = try? Cache.shared.getUser(id: id) {
            completion(user)
            return
        }
        
        get(userOfId: id, completion: completion)
        
    }
    
}

class PoolRequester: Requester {
    
}

class FilterRequester: Requester {
    
    typealias completion = (FilterResult) -> Void
    
    static var filter_url: String { get {
        return base_url + "/filters"
        } }
    
    func get(filterOfId id: Int, completion: @escaping completion) {
        let url = FilterRequester.filter_url + "/\(id).json"
        do {
            try Network.fetch(url: url, params: nil) { data in
                DispatchQueue.global().async {
//                    do {
//                        let result = try UserParser.parse(data: data)
//                        completion(result)
//                    } catch {
//                        print("UserRequester get error: \(data) of url: \(url)")
//                    }
                }
            }
        } catch {
            print("UserRequester Error")
        }
    }
    
}
*/