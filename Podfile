# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'TPKeyboardAvoiding'
    pod 'FBSDKLoginKit'
    pod 'FBSDKCoreKit'
    pod 'Google/SignIn'
    pod 'Google/Analytics'
    pod 'GoogleUtilities', '1.1.0'
    pod 'SDWebImage'
    pod 'TwitterKit'
    pod 'AWSS3', '2.6.2'
    pod 'NYTPhotoViewer'
    pod 'SwiftAddressBook', :git => 'https://github.com/SocialbitGmbH/SwiftAddressBook', :branch => 'chunkyguy-swift3'
    pod 'JSQMessagesViewController'
    pod 'youtube-ios-player-helper', '0.1.6'
    pod 'Proposer', ‘1.1.0’
    pod 'ISScrollViewPageSwift', :git => 'https://github.com/Ilhasoft/ISScrollViewPageSwift', :branch => 'master'
    pod 'DBSphereTagCloud', :git => 'https://github.com/danielblx/DBSphereTagCloud.git'
    pod 'QRCodeReader.swift', '7.2.0'
    pod 'SRKControls', :git => 'https://github.com/Ilhasoft/SRKControls'
    pod 'STTwitter'

    pod 'IlhasoftCore', :git => 'https://bitbucket.org/ilhasoft/ilhasoft-core-ios’, :branch => 'develop'

    pod 'Firebase/Core', '4.0.4'
    pod 'Firebase/Messaging', '4.0.4'
    pod 'Firebase/Auth', '4.0.4'
    pod 'Firebase/Database', '4.0.4'

    pod 'fcm-channel-ios', :git => 'https://github.com/push-flow/fcm-channel-ios.git'

end

target "ureport" do
    shared_pods
end

target "ureport on-the-move" do
    shared_pods
end
