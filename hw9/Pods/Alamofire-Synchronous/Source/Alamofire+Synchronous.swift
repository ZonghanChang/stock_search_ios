//
//  Alamofire+Synchronous.swift
//  Alamofire-Synchronous
//
//  Created by Luda Zhuang on 15/11/8.
//  Copyright © 2015年 Luda Zhuang. All rights reserved.
//

import Foundation
import Alamofire
extension Request {
    public func response() -> (request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: NSError?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: NSError?)!
        self.response(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), completionHandler: { request, response, data, error in
            result = (
                request: request,
                response: response,
                data: data,
                error: error
            )
            semaphore.signal();
        })
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    public func responseData() -> Response<Data, NSError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Response<Data, NSError>!
        self.responseData(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), completionHandler: { response in
            result = response
            semaphore.signal();
        })
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Response<AnyObject, NSError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Response<AnyObject, NSError>!
        self.responseJSON(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: options, completionHandler: {response in
            result = response
            semaphore.signal();
        })
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    public func responseString(encoding: String.Encoding? = nil) -> Response<String, NSError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Response<String, NSError>!
        self.responseString(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), encoding: encoding, completionHandler: { response in
            result = response
            semaphore.signal();
        })
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    public func responsePropertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> Response<AnyObject, NSError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Response<AnyObject, NSError>!
        self.responsePropertyList(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: options, completionHandler: { response in
            result = response
            semaphore.signal();
        })
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
}
