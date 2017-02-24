//
//  ViewPagerOptions.swift
//  ViewPager-Swift
//
//  Created by Nishan on 12/9/16.


import Foundation
import UIKit


class ViewPagerOptions
{
    // MARK: Private Properties
    fileprivate var viewPagerHeight:CGFloat!
    fileprivate var viewPagerWidth:CGFloat!
    
    var anchorView:UIView
    
    //MARK: Booleans 
    
    var isTabViewHighlightAvailable:Bool!
    var isTabIndicatorViewAvailable:Bool!
    var isEachTabEvenlyDistributed: Bool!
    var fitAllTabsInView:Bool!                              /* Overrides isEachTabEvenlyDistributed */
    
    //MARK: Tab View Properties
    
    var tabViewHeight:CGFloat!
    var tabViewWidth:CGFloat!
    var tabViewBackgroundDefaultColor:UIColor!
    var tabViewBackgroundHighlightColor:UIColor!
    var tabViewTextDefaultColor:UIColor!
    var tabViewTextHighlightColor:UIColor!
    var tabLabelPaddingLeft:CGFloat!
    var tabLabelPaddingRight:CGFloat!
    
    
    //MARK: Tab Indicator Properties
    
    var tabIndicatorViewHeight:CGFloat!
    var tabIndicatorViewBackgroundColor:UIColor!
    
    //MARK: View Pager Properties
    var viewPagerTransitionStyle:UIPageViewControllerTransitionStyle!
    
    
    /**
     Initializes Options for ViewPager. The frame of the supplied UIView in view parameter is used as reference for
     ViewPager width and height.
     */
    init(inView view:UIView)
    {
        self.anchorView = view
        
        initDefaults()
    }
   
    /**
     Initializes various properties to its default values
    */
    fileprivate func initDefaults()
    {
        //Tab View Defaults
        self.tabViewHeight = 48
        self.tabViewWidth = self.anchorView.bounds.size.width
        
        //View Pager
        self.viewPagerWidth = self.anchorView.bounds.size.width
        self.viewPagerHeight = self.anchorView.bounds.size.height - tabViewHeight
        
        self.tabViewBackgroundDefaultColor = UIColor(red: CGFloat(255), green: CGFloat(255), blue: CGFloat(255), alpha: 1.0)
        self.tabViewBackgroundHighlightColor = UIColor(red: CGFloat(255.0), green: CGFloat(255.0), blue: CGFloat(255.0), alpha: 1.0)
        self.tabViewTextDefaultColor = UIColor(red: CGFloat(178.0/255.0), green: CGFloat(178.0/255.0), blue: CGFloat(178.0/255.0), alpha: 1.0)
        self.tabViewTextHighlightColor = UIColor.black
        
        self.isTabViewHighlightAvailable = false
        self.isEachTabEvenlyDistributed = false
        self.isTabIndicatorViewAvailable = true
        self.fitAllTabsInView = false
        
        //Tab Indicator View Defaults
        self.tabIndicatorViewHeight = 3
        self.tabIndicatorViewBackgroundColor = UIColor(red: CGFloat(31.0/255.0), green: CGFloat(75.0/255.0), blue: CGFloat(165.0/255.0), alpha: 1.0)
        
        
        // Tab Label Defaults
        self.tabLabelPaddingLeft = 10
        self.tabLabelPaddingRight = 10
        
        //View Pager Defaults
        self.viewPagerTransitionStyle = UIPageViewControllerTransitionStyle.scroll
        
    }
    
    // Getters
    
    func getViewPagerHeight() -> CGFloat
    {
        return self.viewPagerHeight
    }
    
    func getViewPagerWidth() -> CGFloat
    {
        return self.viewPagerWidth
    }
    
    
}
