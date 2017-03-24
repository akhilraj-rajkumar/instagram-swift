//
//  Utilities.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 22/03/17.
//
//

import Foundation

public class Utilities {
    
    public static func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
