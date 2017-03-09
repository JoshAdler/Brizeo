//
//  LocalizableEnum.swift
//  Betiply
//
//  Created by Juan Alberto Uribe Otero on 9/14/15.
//  Copyright © 2015 Betiply. All rights reserved.
//

import Foundation

enum LocalizableString: String {
    case ErrorWithBranchURL = "Sorry, but we can't provide you with the url for invitation. Please try later."
    case InvitedByText = "Invited by "
    case ShareSmsFails = "Sorry, but you can't send a text."
    case ShareTwitterFails = "Sorry, but you can't share the app with Twitter. Please try later."
    case ShareWhatsappFails = "Sorry, but it looks like you don't have Whatsapp app installed."
    case BranchUnavailable = "Sorry, but you can't share the app now. Please try later."
    case SMSShare = "SMS Message"
    case MessangerShare = "Messanger"
    case WhatsappShare = "WhatsApp"
    case EmailShare = "E-Mail"
    case TwitterShare = "Twitter"
    case ConfirmationText = "Do You Really Want To Delete The Match?"
    case NotifyFriendsMainText = "Notify Your Friends"
    case NotifyFriendsDisclaimer = "This will NOT post to your Facebook Timeline"
    case NotifyFriendsInfo = "By notifying your friends you will help build the community and create a better experience.\n\nPlease click Notify to enjoy Brizeo"
    case NotifyFriendsButtonTitle = "Notify"
    case ShareTopText = "Let's Share Brizeo Personally"
    case Share = "Share"
    case RateBrizeo = "Rate Brizeo"
    case RateDescriptionText = "If you enjoy using this app, would you mind taking a moment to rate it? It won't take more than a minute. Thank you for your support!"
    case NoDescriptionText = "Please add a description so others know why this moment is special for you."
    case MomentsMustHave = "Moments \n Must Have a Description!"
    case Later = "Later"
    case LocationDisabled = "Your location services are disabled. Please enable it to get better user experience."
    case LocationDenied = "You didn't granted the app to get your location. Please grant it to get better user experience."
    case Warning = "Warning"
    case Gender = "Gender"
    case NewMatches = "New Matches"
    case Messages = "Messages"
    case MomentsMatches = "Moments matches"
    case Details = "Details"
    case PeopleNotificationStart = "Your Facebook friend "
    case PeopleNotificationEnd = " is now on Brieze as"
    case TryAgain = "Try again"
    
    //Common
    case Back = "Back"
    case Delete = "Delete"
    case Cancel = "Cancel"
    case Ok = "Ok"
    case Success = "Success"
    case CouldNotSendEmail = "Sorry, but you can not send an email."
    case PleaseTryAgain = "Please try again"
    case Brizeo = "Brizeo"
    case Error = "Error"
    case Dismiss = "Dismiss"
    case Block = "Block"
    
    //MARK: - Menu
    case InviteFriends = "Invite Friends"
    case Profile = "Profile"
    case Moments = "Moments"
    case Chats = "Chats"
    
    // MARK: InviteFriends
    case FriendsSuccessfullyInvited = "friends successfully invited"
    case InviteFriendsFromFacebook = "Post to Facebook"
    case ShareWithFriends = "Share with friends"
    case InviteFriendsByEmail = "Invite friends by email"
    case Send = "SEND"
    case SeeRewardsForInvitingYourFriends = "See rewards for inviting your friends"
    case TryBrizeo = "%@ invites you to join Brizeo!"
    case BrizeoInvite = "I found a nice profile for you. Get on Brizeo and let me know that you think :)"
    case BrizeoShareWithFacebook = "Connect at home and abroad."
    case BrizeoShareDescription = "Meet people who share your passions. Brizeo is packed with cool features, including a Moments wall where you can share your favorite experiences. Brizeo allows you to connect at home and abroad."
    case BrizeoShareJoinCommunity = "Join a community that lives life to its fullest!"
    case CheckItOutAt = "Check it out at %@"
    case CheckItOutHere = "<div style='width:90% ;margin-left:5%; font-size: 15px;'>Check it out <a href='%@'>%@</a></div>"
    case BrizeoMailDescription = "<div style='width:90% ;margin-left:5%; font-size: 15px;'>%@</div><br>"
    case BrizeoMailContent = "<div style='width: %lfpx;'><img style='width: %lfpx; margin-left: 5%; margin-top: 20px; height: 100px; border-radius: 3px; border: 1px solid;' src='http://files.parsetfss.com/0693b1ef-dbce-4dc5-b0d9-b2e4d12cf0ab/tfss-5f297102-e834-4964-b2d5-3dd5c59ec4d5-file'><h3 style='width:90% ;margin-left:5%;'>%@ invites you to join Brizeo</h3>%@</div>"
    
    //MARK: - Moments
    case All = "All"
    case MyMatches = "My Matches"
    case MyMoments = "My Moments"
    case LikesTitle = "Likes"
    case DeleteMoment = "Delete this moment"
    case UnableToSaveMoment = "Unable to save Moment"
    case WriteADescription = "Write a description"
    case WriteACapture = "Write a caption..."
    case UploadPhoto = "Upload photo"
    case MomentsMustHaveADescription = "Moments must have a description"
    case MomentsLimit = "Moments are limited to 20 pictures. Please delete one picture before uplading a new one."
    case YouCantLikeYourOwnMoment = "You can't like your own photo"
    case MomentHadBeenReported = "Moment has been reported to the admins."
    case UploadMomentInfoText = "Turning Viewable by ALL off hides the picture from everyone  except the people you've already matched with."
    
    //MARK: - Chat
    case Chat = "Chat"
    case MessageSent = "Sent"
    case MessageDelivered = "Delivered"
    case MessageRead = "Read"
    case MessageSending = "Sending"
    case Call = "Call"
    case SendMessage = "Send Message"
    case CreateContact = "Create Contact"
    case Copy =  "Copy"
    case Me = "Me"
    case ShowLocationError = "Something was wrong trying to show the location"
    case ShowVideoError = "Something was wrong trying to play the video"
    case ShowImageError = "Something was wrong trying to show the image"
    case LoadingVideo = "Loading video"
    case DeleteChatError = "Something was wrong trying to delete the chat"

	//MARK: Matches
    case TapForMoreInformation = "TAP FOR MORE INFO"
    case SwipeToSeeMoreMatches = "SWIPE TO SEE MORE MATCHES"
    case MessageDidntFoundMatches = "No match found.\n Go to Settings: Change location or widen search."
    case NotFoundNotification = "No new match notification found"
    case MessageErrorFetchingMatches = "Unable to retrieve matches at this time"
    case ActiveTimeAgo = "Active %@ ago"
    case Minutes = "%d minute(s)"
    case Hours = "%d hour(s)"
    case Days = "%d day(s)"
    case Weeks = "%d week(s)"
    case Months = "%d month(s)"
    case Years = "%d year(s)"
    case MilesAway = "%@ miles away"
    case OneMilesAway = "One mile away"
    case InterestedIn = "Interested in:"
    case GoBackInterests = "⬅︎ Interests"
    case MutualFriends = "Mutual Friends"
    case Report = "Report"
    case YearsOld = "%d years old"
    
    //MARK: Profile
    case Library = "Library"
    case Camera = "Camera"
    case About = "About"
    case Matches = "Matches"
    case MyMap = "My Trips"
    case Map = "Trips"
    case TakeImageFrom = "Where would you like the image from?"
    case SelectInterest = "Select interest for a moment" 
    case PhotoLibrary = "Photo Library"
    case TakeAPhoto = "Take a photo"
    case TakeAVideo = "Take a video"
    case TakeAMedia = "Take a media"
    case EditOrDelete = "Edit a media or delete"
    case TakeAPhotoFromFacebook = "Take a photo from Facebook"
    case TakeAPhotoFromInstagram = "Take a photo from Instagram"
    case PassionAlertTitle = "Please Select Your Primary Passion"
    case PassionAlertContent = ""
    case SelectPassion = "Select passion"
    case ViewablebyAll = "Viewable by ALL"
    case First = "First"
    case Second = "Second"
    case Third = "Third"
    
    // MARK: Settings
    case Settings = "Settings"
    case Location = "Location"
    case AddLocation = "Add location"
    case IamA = "I am a"
    case Logout = "Log Out"
    case Man = "Man"
    case Woman = "Woman"
    case Couple = "Couple"
    case SearchForOneOrMore = "Search for one or more"
    case Men = "Men"
    case Women = "Women"
    case MenWomen = "Men & Women"
    case Couples = "Couples"
    case AgeRange = "Age Range"
    case SearchDistance = "Search distance:"
    case SelectInterests = "Select your primary passions:"
    case Notification = "Notifications"
    case SaySomethingAboutYourself = "Say something about yourself:"
    case TypeHere = "Type here"
    case Save = "Save"
    case UserSaved = "User preferences saved"
    case Interests = "Passion"
    case SwipeLeftToChat = "Swipe left to chat"
    case MaximumDistance = "Maximum Distance"
    
    
    // MARK: Match
    case ItsAMatch = "It's a Match!"
    case EnjoyBrizeo = "Welcome to Brizeo! \n\nThis is Josh and David, Co-Founders of Brizeo. We are excited that you have chosen to join us on this journey!\n\nBrizeo connects people that have a passion and desire to explore the world.\n\n❖\tGo to your Settings and choose your search criteria or change your location.\n\n❖\tClick the up arrow on the Profile page to select your Interests and complete your bio. Add your travels in the Trips section.\n\n❖\tAdd your favorite picture to the Moments section. Show people your passion for life and travel!\n\n❖\tClick the Search icon to connect with other users and start chatting.\n\n❖\tInvite your friends! Be selective. We want to create a vibrant and fun atmosphere.\n\nWe hope you love the experience and we always enjoy feedback!"
    case LetTheJourneyBegin = "Let the journey begin."
    case StartChatting = "Start chatting"
    case ReturnToSearch = "Return to search"
    case YouveMatchedWith = "%@ wants to match with you"
    
    // MARK: Trips
    case SearchCountries = "Select countries you've been to..."
    
    // MARK: User Report
    case UserHadBeenReported = "User has been reported to the admins."
    
    // MARK: Push Notifications
    case SomebodySentYouAMessage = "%@ sent you a message."
    case SomebodyLikeYourMoment = "%@ liked your Moments picture."
    case SomebodyMatchYou = "New potential match with %@!"
    case People = "People"
    case LikeNotificationMessage = "liked your moment."
    
    // MARK: - Tutorial
    case Skip = "Skip"
    case Done = "Done"
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    func localizedStringWithArguments(_ arguments: [CVarArg]) -> String {
        
        return String(format: self.localizedString, arguments: arguments)
    }
}

enum PushType: String {
    case Match = "Match"
    case LikeMoment = "LikeMoment"
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
