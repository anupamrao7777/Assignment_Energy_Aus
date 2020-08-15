//
//  CommomMethods.swift
//  MusicFestivalDemo
//
//  Created by Anupam Rao on 16/8/20.
//  Copyright © 2020 Serhii Kharauzov. All rights reserved.
//

import Foundation

class CommomMethods : NSObject{
    /**
            Sort array object in alphabetic order
          - Parameter :  Unsorted array
          - Returns: Sorted array
          */
    func sortedStringArrayAlphabatically(arrayToSort : NSArray) ->[Any] {
        let sortedArray = arrayToSort.sorted { ((($0) as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending) }
        return sortedArray ;
    }
    /**
            Removes empty object from array
          - Parameter : arrayToCheck -  Array with empty string
          - Returns: Array without empty string
          */
    func removeEmptyStringFromArray(arrayToCheck : NSArray) -> [Any] {
        let predicate = NSPredicate(format: "length > 0")
        return arrayToCheck.filtered(using: predicate)
        
    }
    /**
        Finds the index of a string in array
       - Parameter : searchValuey - The string to be searched
                  array - the array in which string is to be searched
       - Returns: the index of string in array``
       */
       func find(value searchValue: String, in array: [Bands.bands]) -> Int?
       {
           for (index, value) in array.enumerated()
           {
               if value.bandNmae == searchValue {
                   return index
               }
           }
           return nil
       }
}

