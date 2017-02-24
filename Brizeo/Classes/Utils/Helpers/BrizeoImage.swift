//
//  BrizeoImage.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/14/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

enum BrizeoImage: String {
    
    //MARK: - Common
    case SearchIcon = "ic_search"
    case SettingIcon = "ic_settings"
    // MARK: Invites
    case BrizeoPromo = "Swimming"
    case BrizeoLogoImage = "http://files.parsetfss.com/0693b1ef-dbce-4dc5-b0d9-b2e4d12cf0ab/tfss-5f297102-e834-4964-b2d5-3dd5c59ec4d5-file"
    
    //MARK: - Menu
    case InviteFriendsGrey = "nav-add-friends-grey.png"
    case InviteFriendsBlue = "nav-add-friends-blue.png"
    case EventGrey = "ic_tabBar_event"
    case EventBlue = "ic_tabBar_event_selected"
    case NotificationBlue = "ic_tabBar_notification_selected"
    case NotificationGrey = "ic_tabBar_notification"
    case SearchMatchesGrey = "ic_tabBar_search"
    case SearchMatchesBlue = "ic_tabBar_search_selected"
    case ProfileGrey = "nav-profile-settings-grey.png"
    case ProfileBlue = "nav-profile-settings-blue.png"
    case MomentsGrey = "ic_tabBar_moments"
    case MomentsBlue = "ic_tabBar_moments_selected"
    case ChatGrey = "ic_tabBar_chat"
    case ChatBlue = "ic_tabBar_chat_selected"
    
    //MARK: - Moments
    case CameraIcon = "camera-icon.png"
    
    //MARK: - Events
    case locationIcon = "ic_location"
    case filterIcon = "ic_filter"
    
    //MARK: - Chat
    case ChatImagePlaceholder = "placeholder.png"
    
    // MARK: Matches
    case EmptyImage = "add_icon.png"
    
    // MARK: Profile
    case AddImage = "ic_add_photo_plus"
    
    case SharingImage = "share-icon"
    
    // MARK: - Tutorial
    case Intro1 = "intro1"
    case Setting = "setting2"
    case Profile = "profile3"
    case Match = "match4"
    case Moments = "moments5"
    case MainPage2 = "main_page_2"
    case Moments1 = "moments_1"
    case Moments2 = "moments_2"
    case Moments3 = "moments_3"
    
    var image: UIImage {
        return UIImage(named: self.rawValue)!
    }
}
