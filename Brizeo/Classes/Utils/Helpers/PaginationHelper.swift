//
//  PaginationHelper.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation

struct PaginationHelper {
    
    fileprivate let defaultPageValue = 1
    fileprivate var initialPage: Int
    fileprivate(set) var elementsPerPage: Int
    fileprivate(set) var currentPage: Int
    fileprivate(set) var totalElements: Int
    
    var nextPage: Int {
        return currentPage + 1
    }
    
    var previousPage: Int {
        return currentPage - 1
    }
    
    init(pagesSize: Int) {
        
        elementsPerPage = pagesSize
        self.initialPage = defaultPageValue
        currentPage = defaultPageValue
        totalElements = 0
    }
    
    init(initialPage: Int, pagesSize: Int) {
        
        self.init(pagesSize: pagesSize)
        self.initialPage = initialPage
    }
    
    mutating func increaseCurrentPage() {
        currentPage += 1
    }
    
    mutating func resetPages() {
        currentPage = initialPage
        totalElements = 0
    }
    
    func isFirstPage() -> Bool {
        return currentPage == initialPage
    }
    
    mutating func addNewElements<T>(_ currentElements: inout [T], newElements: [T]) {
        
        if newElements.isEmpty {
            return
        }
        
        if isFirstPage() {
            currentElements = newElements
        } else {
            currentElements.append(contentsOf: newElements)
        }
        totalElements = currentElements.count
    }
}
