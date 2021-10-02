/*
MIT License
Copyright (c) 2018 toddheasley
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//
//  CGifManager.swift
//  GifMaker
//
//  Created by Coder ACJHP on 25.02.2019.
//  Copyright © 2019 Coder ACJHP. All rights reserved.
//
import UIKit
import ImageIO
import MobileCoreServices

class CGifManager {
    
    static let shared = CGifManager()
    
    typealias SequenceCompletionHandler = ([UIImage]) -> ()
    typealias GenerateCompletionHandler = (String?) -> ()
    
    func getSequence(imageData: Data, completionHandler: SequenceCompletionHandler) {
        
        let gifOptions = [
            kCGImageSourceShouldAllowFloat as String : kCFBooleanFalse,
            kCGImageSourceCreateThumbnailWithTransform as String : kCFBooleanFalse,
            kCGImageSourceCreateThumbnailFromImageAlways as String : kCFBooleanFalse,
            kCGImageSourceShouldCacheImmediately as String : kCFBooleanFalse,
            ] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, gifOptions) else {
            debugPrint("Cannot create image source with data!"); return
        }
        
        let framesCount = CGImageSourceGetCount(imageSource)
        
        var imageProperties = [CFDictionary]()
        for i in 0 ..< framesCount {
            guard let dict = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else { continue }
            imageProperties.append(dict)
        }
        
        var frameList: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        for index in 0 ..< framesCount {
            dispatchGroup.enter()
            guard let cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, imageProperties[index]) else { continue }
            frameList.append(UIImage(cgImage: cgImageRef))
            dispatchGroup.leave()
        }
        
        dispatchGroup.wait()
        completionHandler(frameList)
    }
}
