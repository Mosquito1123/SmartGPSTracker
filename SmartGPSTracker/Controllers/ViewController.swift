//
//  ViewController.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit
import CoreGPX


/// Purple color for button background
let kPurpleButtonBackgroundColor: UIColor =  UIColor(red: 146.0/255.0, green: 166.0/255.0, blue: 218.0/255.0, alpha: 0.90)

/// Green color for button background
let kGreenButtonBackgroundColor: UIColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)

/// Red color for button background
let kRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.90)

/// Blue color for button background
let kBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.90)

/// Blue color for disabled button background
let kDisabledBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.10)

/// Red color for disabled button background
let kDisabledRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.10)

/// White color for button background
let kWhiteBackgroundColor: UIColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.90)

/// Delete Waypoint Button tag. Used in a waypoint bubble
let kDeleteWaypointAccesoryButtonTag = 666

/// Edit Waypoint Button tag. Used in a waypoint bubble.
let kEditWaypointAccesoryButtonTag = 333

/// Text to display when the system is not providing coordinates.
let kNotGettingLocationText = "Not getting location"

/// Text to display unknown accuracy
let kUnknownAccuracyText = "±···"

/// Text to display unknown speed.
let kUnknownSpeedText = "·.··"

/// Size for small buttons
let kButtonSmallSize: CGFloat = 48.0

/// Size for large buttons
let kButtonLargeSize: CGFloat = 96.0

/// Separation between buttons
let kButtonSeparation: CGFloat = 6.0

/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy6 = 6.0
/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy5 = 11.0
/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy4 = 31.0
/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy3 = 51.0
/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy2 = 101.0
/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy1 = 201.0

///
/// Main View Controller of the Application. It is loaded when the application is launched
///
/// Displays a map and a set the buttons to control the tracking
///
///
class ViewController: UIViewController, UIGestureRecognizerDelegate  {
    
    /// Shall the map be centered on current user position?
    /// If yes, whenever the user moves, the center of the map too.
    var followUser: Bool = true {
        didSet {
            if followUser {
                print("followUser=true")
                followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                print("followUser=false")
                followUserButton.setImage(UIImage(named: "follow_user"), for: UIControl.State())
            }
            
        }
    }
    
    /// TBD (not currently used)
    var followUserBeforePinchGesture = true
    
    
    /// location manager instance configuration
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.headingFilter = 1 //degrees (1 is default)
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager
    }()
    
    /// Map View
    var map: GPXMapView
    
    /// Map View delegate
    let mapViewDelegate = MapViewDelegate()
    
    /// Stop watch instance to control elapsed time
    var stopWatch = StopWatch()
    
    /// Name of the last file that was saved (without extension)
    var lastGpxFilename: String = ""
    
    /// Status variable that indicates if the app was sent to background.
    var wasSentToBackground: Bool = false
    
    /// Status variable that indicates if the location service auth was denied.
    var isDisplayingLocationServicesDenied: Bool = false
    
    /// Has the map any waypoint?
    var hasWaypoints: Bool = false {
        /// Whenever it is updated, if it has waypoints it sets the save and reset button
        didSet {
            if hasWaypoints {
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
            }
        }
    }
    
    
    /// Defines the different statuses regarding tracking current user location.
    enum GpxTrackingStatus {
        
        /// Tracking has not started or map was reset
        case notStarted
        
        /// Tracking is ongoing
        case tracking
        
        /// Tracking is paused (the map has some contents)
        case paused
    }
    
    /// Tells what is the current status of the Map Instance.
    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.notStarted {
        didSet {
            print("gpxTrackingStatus changed to \(gpxTrackingStatus)")
            switch gpxTrackingStatus {
            case .notStarted:
                print("switched to non started")
                // set Tracker button to allow Start
                trackerButton.setTitle("Start Tracking", for: UIControl.State())
                trackerButton.backgroundColor = kGreenButtonBackgroundColor
                //save & reset button to transparent.
                saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
                resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
                //reset clock
                stopWatch.reset()
                timeLabel.text = stopWatch.elapsedTimeString
                
                map.clearMap() //clear map
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                totalTrackedDistanceLabel.distance = (map.session.totalTrackedDistance)
                currentSegmentDistanceLabel.distance = (map.session.currentSegmentDistance)
                
                /*
                 // XXX Left here for reference
                 UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                 self.trackerButton.hidden = true
                 self.pauseButton.hidden = false
                 }, completion: {(f: Bool) -> Void in
                 println("finished animation start tracking")
                 })
                 */
                
            case .tracking:
                print("switched to tracking mode")
                // set tracerkButton to allow Pause
                trackerButton.setTitle("Pause", for: UIControl.State())
                trackerButton.backgroundColor = kPurpleButtonBackgroundColor
                //activate save & reset buttons
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
                // start clock
                self.stopWatch.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle("Resume", for: UIControl.State())
                self.trackerButton.backgroundColor = kGreenButtonBackgroundColor
                // activate save & reset (just in case switched from .NotStarted)
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }
    
    /// Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.
    
    
    //UI
    /// Label with the title of the app
    var appTitleLabel: UILabel
    
    /// Image with the GPS signal
    var signalImageView: UIImageView
    
    /// Current GPS signal accuracy text (based on kSignalAccuracyX constants)
    var signalAccuracyLabel: UILabel
    
    /// Label that displays current latitude and longitude (lat,long)
    var coordsLabel: UILabel
    
    /// Displays current elapsed time (00:00)
    var timeLabel: UILabel
    
    /// Label that displays last known speed (in km/h)
    var speedLabel: UILabel
    
    /// Distance of the total segments tracked
    var totalTrackedDistanceLabel: DistanceLabel
    
    /// Distance of the current segment being tracked (since last time the Tracker button was pressed)
    var currentSegmentDistanceLabel: DistanceLabel
    
    /// Used to display in imperial (foot, miles, mph) or metric system (m, km, km/h)
    var useImperial = false
    
    /// Follow user button (bottom bar)
    var followUserButton: UIButton
    
    /// New pin button (bottom bar)
    var newPinButton: UIButton
    
    /// View GPX Files button
    var folderButton: UIButton
    
    /// View app about button
    var aboutButton: UIButton
    
    /// View preferences button
    var preferencesButton: UIButton
    
    /// Share current gpx file button
    var shareButton: UIButton
    
    /// Spinning Activity Indicator for shareButton
    let shareActivityIndicator: UIActivityIndicatorView
    
    /// Reset map button (bottom bar)
    var resetButton: UIButton
    
    /// Start/Pause tracker button (bottom bar)
    var trackerButton: UIButton
    
    /// Save current track into a GPX file
    var saveButton: UIButton
    
    // Signal accuracy images
    /// GPS signal image. Level 0 (no signal)
    let signalImage0 = UIImage(named: "signal0")
    /// GPS signal image. Level 1
    let signalImage1 = UIImage(named: "signal1")
    /// GPS signal image. Level 2
    let signalImage2 = UIImage(named: "signal2")
    /// GPS signal image. Level 3
    let signalImage3 = UIImage(named: "signal3")
    /// GPS signal image. Level 4
    let signalImage4 = UIImage(named: "signal4")
    /// GPS signal image. Level 5
    let signalImage5 = UIImage(named: "signal5")
    /// GPS signal image. Level 6
    let signalImage6 = UIImage(named: "signal6")
    
    /// Initializer. Just initializes the class vars/const
    required init(coder aDecoder: NSCoder) {
        self.map = GPXMapView(coder: aDecoder)!
        
        self.appTitleLabel = UILabel(coder: aDecoder)!
        self.signalImageView = UIImageView(coder: aDecoder)!
        self.signalAccuracyLabel = UILabel(coder: aDecoder)!
        self.coordsLabel = UILabel(coder: aDecoder)!
        
        self.timeLabel = UILabel(coder: aDecoder)!
        self.speedLabel = UILabel(coder: aDecoder)!
        self.totalTrackedDistanceLabel = DistanceLabel(coder: aDecoder)!
        self.currentSegmentDistanceLabel = DistanceLabel(coder: aDecoder)!
        
        self.followUserButton = UIButton(coder: aDecoder)!
        self.newPinButton = UIButton(coder: aDecoder)!
        self.folderButton = UIButton(coder: aDecoder)!
        self.resetButton = UIButton(coder: aDecoder)!
        self.aboutButton = UIButton(coder: aDecoder)!
        self.preferencesButton = UIButton(coder: aDecoder)!
        self.shareButton = UIButton(coder: aDecoder)!
        
        self.trackerButton = UIButton(coder: aDecoder)!
        self.saveButton = UIButton(coder: aDecoder)!
        
        self.shareActivityIndicator = UIActivityIndicatorView(coder: aDecoder)
        
        super.init(coder: aDecoder)!
    }
    
    ///
    /// De initalize the ViewController.
    ///
    /// Current implementation removes notification observers
    ///
    deinit {
        print("*** deinit")
        removeNotificationObservers()
    }
    
    
    ///
    /// Initializes the view. It adds the UI elements to the view.
    ///
    /// All the UI is built programatically on this method. Interface builder is not used.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatch.delegate = self
        
        //Because of the edges, iPhone X* is slightly different on the layout.
        //So, Is the current device an iPhone X?
        var isIPhoneX = false
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("device: IPHONE 5,5S,5C")
            case 1334:
                print("device: IPHONE 6,7,8 IPHONE 6S,7S,8S ")
            case 1920, 2208:
                print("device: IPHONE 6PLUS, 6SPLUS, 7PLUS, 8PLUS")
            case 2436:
                print("device: IPHONE X, IPHONE XS")
                isIPhoneX = true
            case 2688:
                print("device: IPHONE XS_MAX")
                isIPhoneX = true
            case 1792:
                print("device: IPHONE XR")
                isIPhoneX = true
            default:
                print("UNDETERMINED")
            }
        }
        
        // Map autorotate configuration
        map.autoresizesSubviews = true
        map.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.autoresizesSubviews = true
        self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // Map configuration Stuff
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - (isIPhoneX ? 0.0 : 20.0)
        map.frame = CGRect(x: 0.0, y: (isIPhoneX ? 0.0 : 20.0), width: self.view.bounds.size.width, height: mapH)
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        //set the position of the compass.
        map.compassRect = CGRect(x: map.frame.width/2 - 18, y: isIPhoneX ? 105.0 : 70.0 , width: 36, height: 36)
        
        //If user long presses the map, it will add a Pin (waypoint) at that point
        map.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinAtTappedLocation(_:)))
        )
        
        //Each time user pans, if the map is following the user, it stops doing that.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture")
        //map.addGestureRecognizer(pinchGesture)
        
        //Preferences
        map.tileServer = Preferences.shared.tileServer
        map.useCache = Preferences.shared.useCache
        useImperial = Preferences.shared.useImperial
        
        
        //
        // Config user interface
        //
        
        // Set default zoom
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        addNotificationObservers()
        
        //
        // ---------------------- Build Interface Area -----------------------------
        //
        // HEADER
        let font36 = UIFont(name: "DinCondensed-Bold", size: 36.0)
        let font18 = UIFont(name: "DinAlternate-Bold", size: 18.0)
        let font12 = UIFont(name: "DinAlternate-Bold", size: 12.0)
        
        //add the app title Label (Branding, branding, branding! )
        let appTitleW: CGFloat = self.view.frame.width//200.0
        let appTitleH: CGFloat = 14.0
        let appTitleX: CGFloat = 0 //self.view.frame.width/2 - appTitleW/2
        let appTitleY: CGFloat = isIPhoneX ? 40.0 : 20.0
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "  Smart GPX Tracker"
        appTitleLabel.textAlignment = .left
        appTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        //appTitleLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        appTitleLabel.textColor = UIColor.yellow
        appTitleLabel.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        appTitleLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        self.view.addSubview(appTitleLabel)
        
        // CoordLabel
        coordsLabel.frame = CGRect(x: self.map.frame.width - 305, y: appTitleY, width: 300, height: 12)
        coordsLabel.textAlignment = .right
        coordsLabel.font = font12
        coordsLabel.textColor = UIColor.white
        coordsLabel.text = kNotGettingLocationText
        coordsLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        self.view.addSubview(coordsLabel)
        
        // Tracked info
        let iPhoneXdiff: CGFloat  = isIPhoneX ? 40 : 0
        //timeLabel
        timeLabel.frame = CGRect(x: self.map.frame.width - 160, y: 20 + iPhoneXdiff, width: 150, height: 40)
        timeLabel.textAlignment = .right
        timeLabel.font = font36
        timeLabel.text = "00:00"
        timeLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        //timeLabel.shadowColor = UIColor.whiteColor()
        //timeLabel.shadowOffset = CGSize(width: 1, height: 1)
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(timeLabel)
        
        //speed Label
        speedLabel.frame = CGRect(x: self.map.frame.width - 160,  y: 20 + 36 + iPhoneXdiff, width: 150, height: 20)
        speedLabel.textAlignment = .right
        speedLabel.font = font18
        speedLabel.text = 0.00.toSpeed(useImperial: useImperial)
        speedLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(speedLabel)
        
        //tracked distance
        totalTrackedDistanceLabel.frame = CGRect(x: self.map.frame.width - 160, y: 60 + 20 + iPhoneXdiff, width: 150, height: 40)
        totalTrackedDistanceLabel.textAlignment = .right
        totalTrackedDistanceLabel.font = font36
        totalTrackedDistanceLabel.text = 0.00.toDistance(useImperial: useImperial)
        totalTrackedDistanceLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(totalTrackedDistanceLabel)
        
        currentSegmentDistanceLabel.frame = CGRect(x: self.map.frame.width - 160, y: 80 + 36 + iPhoneXdiff, width: 150, height: 20)
        currentSegmentDistanceLabel.textAlignment = .right
        currentSegmentDistanceLabel.font = font18
        currentSegmentDistanceLabel.text =  0.00.toDistance(useImperial: useImperial)
        currentSegmentDistanceLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(currentSegmentDistanceLabel)
        
        //about button
        aboutButton.frame = CGRect(x: 5 + 8, y: 14 + 5 + 48 + 5 + iPhoneXdiff, width: 32, height: 32)
        aboutButton.setImage(UIImage(named: "info"), for: UIControl.State())
        aboutButton.setImage(UIImage(named: "info_high"), for: .highlighted)
        aboutButton.addTarget(self, action: #selector(ViewController.openAboutViewController), for: .touchUpInside)
        aboutButton.autoresizingMask = [.flexibleRightMargin]
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(aboutButton)
        
        // Preferences button
        preferencesButton.frame = CGRect(x: 5 + 10 + 48, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
        preferencesButton.setImage(UIImage(named: "prefs"), for: UIControl.State())
        preferencesButton.setImage(UIImage(named: "prefs_high"), for: .highlighted)
        preferencesButton.addTarget(self, action: #selector(ViewController.openPreferencesTableViewController), for: .touchUpInside)
        preferencesButton.autoresizingMask = [.flexibleRightMargin]
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(preferencesButton)
        
        // Share button
        shareButton.frame = CGRect(x: 5 + 10 + 48 * 2, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
        shareButton.setImage(UIImage(named: "share"), for: UIControl.State())
        shareButton.setImage(UIImage(named: "share_high"), for: .highlighted)
        shareButton.addTarget(self, action: #selector(ViewController.openShare), for: .touchUpInside)
        shareButton.autoresizingMask = [.flexibleRightMargin]
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(shareButton)
        
        // Folder button
        let folderW: CGFloat = kButtonSmallSize
        let folderH: CGFloat = kButtonSmallSize
        let folderX: CGFloat = folderW/2 + 5
        let folderY: CGFloat = folderH/2 + 5 + 14  + iPhoneXdiff
        folderButton.frame = CGRect(x: 0, y: 0, width: folderW, height: folderH)
        folderButton.center = CGPoint(x: folderX, y: folderY)
        folderButton.setImage(UIImage(named: "folder"), for: UIControl.State())
        folderButton.setImage(UIImage(named: "folderHigh"), for: .highlighted)
        folderButton.addTarget(self, action: #selector(ViewController.openFolderViewController), for: .touchUpInside)
        folderButton.backgroundColor = kWhiteBackgroundColor
        folderButton.layer.cornerRadius = 24
        folderButton.autoresizingMask = [.flexibleRightMargin]
        map.addSubview(folderButton)
        
        // Add signal accuracy images and labels
        signalImageView.image = signalImage0
        signalImageView.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5 + iPhoneXdiff, width: 50, height: 30)
        signalImageView.autoresizingMask  = [.flexibleLeftMargin, .flexibleRightMargin]
        map.addSubview(signalImageView)
        signalAccuracyLabel.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5 + 30 + iPhoneXdiff , width: 50, height: 12)
        signalAccuracyLabel.font = font12
        signalAccuracyLabel.text = kUnknownAccuracyText
        signalAccuracyLabel.textAlignment = .center
        signalAccuracyLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        map.addSubview(signalAccuracyLabel)
        
        
        //
        // Button Bar
        //
        // [ Small ] [ Small ] [ Large     ] [Small] [ Small]
        //                     [ (tracker) ]
        //
        //                     [ track     ]
        // [ follow] [ +Pin  ] [ Pause     ] [ Save ] [ Reset]
        //                     [ Resume    ]
        //
        //                       trackerX
        //                         |
        //                         |
        // [-----------------------|--------------------------]
        //                  map.frame/2 (center)
        
        let yCenterForButtons: CGFloat = map.frame.height - kButtonLargeSize/2 - 5 //center Y of start
        
        
        // Start/Pause button
        let trackerW: CGFloat = kButtonLargeSize
        let trackerH: CGFloat = kButtonLargeSize
        let trackerX: CGFloat = self.map.frame.width/2 - 0.0 // Center of start
        let trackerY: CGFloat = yCenterForButtons
        trackerButton.frame = CGRect(x: 0, y:0, width: trackerW, height: trackerH)
        trackerButton.center = CGPoint(x: trackerX, y: trackerY)
        trackerButton.layer.cornerRadius = trackerW/2
        trackerButton.setTitle("Start Tracking", for: UIControl.State())
        trackerButton.backgroundColor = kGreenButtonBackgroundColor
        trackerButton.addTarget(self, action: #selector(ViewController.trackerButtonTapped), for: .touchUpInside)
        trackerButton.isHidden = false
        trackerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .center
        trackerButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        map.addSubview(trackerButton)
        
        // Pin Button (on the left of start)
        let newPinW: CGFloat = kButtonSmallSize
        let newPinH: CGFloat = kButtonSmallSize
        let newPinX: CGFloat = trackerX - trackerW/2 - kButtonSeparation - newPinW/2
        let newPinY: CGFloat = yCenterForButtons
        newPinButton.frame = CGRect(x: 0, y: 0, width: newPinW, height: newPinH)
        newPinButton.center = CGPoint(x: newPinX, y: newPinY)
        newPinButton.layer.cornerRadius = newPinW/2
        newPinButton.backgroundColor = kWhiteBackgroundColor
        newPinButton.setImage(UIImage(named: "addPin"), for: UIControl.State())
        newPinButton.setImage(UIImage(named: "addPinHigh"), for: .highlighted)
        newPinButton.addTarget(self, action: #selector(ViewController.addPinAtMyLocation), for: .touchUpInside)
        newPinButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        //let newPinLongPress = UILongPressGestureRecognizer(target: self, action: Selector("newPinLongPress:"))
        //newPinButton.addGestureRecognizer(newPinLongPress)
        map.addSubview(newPinButton)
        
        // Follow user button
        let followW: CGFloat = kButtonSmallSize
        let followH: CGFloat = kButtonSmallSize
        let followX: CGFloat = newPinX - newPinW/2 - kButtonSeparation - followW/2
        let followY: CGFloat = yCenterForButtons
        followUserButton.frame = CGRect(x: 0, y: 0, width: followW, height: followH)
        followUserButton.center = CGPoint(x: followX, y: followY)
        followUserButton.layer.cornerRadius = followW/2
        followUserButton.backgroundColor = kWhiteBackgroundColor
        //follow_user_high represents the user is being followed. Default status when app starts
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: .highlighted)
        followUserButton.addTarget(self, action: #selector(ViewController.followButtonTroggler), for: .touchUpInside)
        followUserButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        map.addSubview(followUserButton)
        
        // Save button
        let saveW: CGFloat = kButtonSmallSize
        let saveH: CGFloat = kButtonSmallSize
        let saveX: CGFloat = trackerX + trackerW/2 + kButtonSeparation + saveW/2
        let saveY: CGFloat = yCenterForButtons
        saveButton.frame = CGRect(x: 0, y: 0, width: saveW, height: saveH)
        saveButton.center = CGPoint(x: saveX, y: saveY)
        saveButton.layer.cornerRadius = saveW/2
        saveButton.setTitle("Save", for: UIControl.State())
        saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
        saveButton.addTarget(self, action: #selector(ViewController.saveButtonTapped), for: .touchUpInside)
        saveButton.isHidden = false
        saveButton.titleLabel?.textAlignment = .center
        saveButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        map.addSubview(saveButton)
        
        // Reset button
        let resetW: CGFloat = kButtonSmallSize
        let resetH: CGFloat = kButtonSmallSize
        let resetX: CGFloat = saveX + saveW/2 + kButtonSeparation + resetW/2
        let resetY: CGFloat = yCenterForButtons
        resetButton.frame = CGRect(x: 0, y: 0, width: resetW, height: resetH)
        resetButton.center = CGPoint(x: resetX, y: resetY)
        resetButton.layer.cornerRadius = resetW/2
        resetButton.setTitle("Reset", for: UIControl.State())
        resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
        resetButton.addTarget(self, action: #selector(ViewController.resetButtonTapped), for: .touchUpInside)
        resetButton.isHidden = false
        resetButton.titleLabel?.textAlignment = .center
        resetButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        map.addSubview(resetButton)
    }
    
    ///
    /// Asks the system to notify the app on some events
    ///
    /// Current implementation requests the system to notify the app:
    ///
    ///  1. whenever it enters background
    ///  2. whenever it becomes active
    ///  3. whenever it will terminate
    ///  4. whenever it receives a file from Apple Watch
    ///
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(ViewController.didEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(presentReceivedFile(_:)), name: .didReceiveFileFromAppleWatch, object: nil)
        
    }
    
    ///
    /// Removes the notification observers
    ///
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    ///
    /// Presents alert when file received from Apple Watch
    ///
    @objc func presentReceivedFile(_ notification: Notification) {
        
        guard let fileName = notification.userInfo?["fileName"] as? String? else { return }
        
        // alert to display to notify user that file has been received.
        let controller = UIAlertController(title: "File Received from Apple Watch", message: "Received file: \"\(fileName ?? "")\"", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) {
            (action) in
            print("ViewController:: Presented file received message from WatchConnectivity Session")
        }
        
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    
    /// returns a string with the format of current date dd-MMM-yyyy-HHmm' (20-Jun-2018-1133)
    ///
    func defaultFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
        print("fileName:" + dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
    }
    
    ///
    /// Called when the application Becomes active (background -> foreground) this function verifies if
    /// it has permissions to get the location.
    ///
    @objc func applicationDidBecomeActive() {
        print("viewController:: applicationDidBecomeActive wasSentToBackground: \(wasSentToBackground) locationServices: \(CLLocationManager.locationServicesEnabled())")
        
        //If the app was never sent to background do nothing
        if !wasSentToBackground {
            return
        }
        checkLocationServicesStatus()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    ///
    /// Actions to do in case the app entered in background
    ///
    /// In current implementation if the app is not tracking it requests the OS to stop
    /// sharing the location to save battery.
    ///
    ///
    @objc func didEnterBackground() {
        wasSentToBackground = true // flag the application was sent to background
        print("viewController:: didEnterBackground")
        if gpxTrackingStatus != .tracking {
            locationManager.stopUpdatingLocation()
        }
    }
    
    ///
    /// Actions to do when the app will terminate
    ///
    /// In current implementation it removes all the temporary files that may have been created
    @objc func applicationWillTerminate() {
        print("viewController:: applicationWillTerminate")
        GPXFileManager.removeTemporaryFiles()
    }
    
    ///
    /// Displays the view controller with the list of GPX Files.
    ///
    @objc func openFolderViewController() {
        print("openFolderViewController")
        let vc = GPXFilesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
    ///
    /// Displays the view controller with the About information.
    ///
    @objc func openAboutViewController() {
        let vc = AboutViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
    ///
    /// Opens Preferences table view controller
    ///
    @objc func openPreferencesTableViewController() {
        print("openPreferencesTableViewController")
        let vc = PreferencesTableViewController(style: .grouped)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
    /// Opens an Activity View Controller to share the file
    @objc func openShare() {
        print("ViewController: Share Button tapped")
        
        // async such that process is done in background
        DispatchQueue.global(qos: .utility).async {
            // UI code
            DispatchQueue.main.sync {
                self.shouldShowShareActivityIndicator(true)
            }
            
            //Create a temporary file
            let filename =  self.lastGpxFilename.isEmpty ? self.defaultFilename() : self.lastGpxFilename
            let gpxString: String = self.map.exportToGPXString()
            let tmpFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filename).gpx")
            GPXFileManager.saveToURL(tmpFile, gpxContents: gpxString)
            //Add it to the list of tmpFiles.
            //Note: it may add more than once the same file to the list.
            
            // UI code
            DispatchQueue.main.sync {
                //Call Share activity View controller
                let activityViewController = UIActivityViewController(activityItems: [tmpFile], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.shareButton
                activityViewController.popoverPresentationController?.sourceRect = self.shareButton.bounds
                self.present(activityViewController, animated: true, completion: nil)
                self.shouldShowShareActivityIndicator(false)
            }
            
        }
    }
    
    /// Displays spinning activity indicator for share button when true
    func shouldShowShareActivityIndicator(_ isTrue: Bool) {
        // setup
        shareActivityIndicator.color = .black
        shareActivityIndicator.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        shareActivityIndicator.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        if isTrue {
            // cross dissolve from button to indicator
            UIView.transition(with: self.shareButton, duration: 0.35, options: [.transitionCrossDissolve], animations: {
                self.shareButton.addSubview(self.shareActivityIndicator)
            }, completion: nil)
            
            shareActivityIndicator.startAnimating()
            shareButton.setImage(nil, for: UIControl.State())
            shareButton.isUserInteractionEnabled = false
        }
        else {
            // cross dissolve from indicator to button
            UIView.transition(with: self.shareButton, duration: 0.35, options: [.transitionCrossDissolve], animations: {
                self.shareActivityIndicator.removeFromSuperview()
            }, completion: nil)
            
            shareActivityIndicator.stopAnimating()
            shareButton.setImage(UIImage(named: "share"), for: UIControl.State())
            shareButton.isUserInteractionEnabled = true
        }
    }
    
    ///
    /// After invoking this fuction, the map will not be centered on current user position.
    ///
    @objc func stopFollowingUser(_ gesture: UIPanGestureRecognizer) {
        if self.followUser {
            self.followUser = false
        }
    }
    
    ///
    /// UIGestureRecognizerDelegate required for stopFollowingUser
    ///
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    ///
    /// If user long presses the map for a while a Pin (Waypoint/Annotation) will be dropped at that point.
    ///
    @objc func addPinAtTappedLocation(_ gesture: UILongPressGestureRecognizer) {
        if  gesture.state == UIGestureRecognizer.State.began {
            print("Adding Pin map Long Press Gesture")
            let point: CGPoint = gesture.location(in: self.map)
            map.addWaypointAtViewPoint(point)
            //Allows save and reset
            self.hasWaypoints = true
        }
    }
    
    /// Does nothing in current implementation.
    func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        print("pinchGesture")
        /*   if gesture.state == UIGestureRecognizerState.Began {
         self.followUserBeforePinchGesture = self.followUser
         self.followUser = false
         }
         //return to back
         if gesture.state == UIGestureRecognizerState.Ended {
         self.followUser = self.followUserBeforePinchGesture
         }
         */
    }
    
    ///
    /// It adds a Pin (Waypoint/Annotation) to current user location.
    ///
    @objc func addPinAtMyLocation() {
        print("Adding Pin at my location")
        let altitude = map.userLocation.location?.altitude
        let waypoint = GPXWaypoint(coordinate: map.userLocation.coordinate, altitude: altitude)
        map.addWaypoint(waypoint)
        self.hasWaypoints = true
    }
    
    ///
    /// Triggered when follow Button is taped.
    //
    /// Trogles between following or not following the user, that is, automatically centering the map
    //  in current user´s position.
    ///
    @objc func followButtonTroggler() {
        self.followUser = !self.followUser
    }
    
    ///
    /// Triggered when reset button was tapped.
    ///
    /// It sets map to status .notStarted which clears the map.
    ///
    @objc func resetButtonTapped() {
        self.gpxTrackingStatus = .notStarted
    }
    
    
    ///
    /// Main Start/Pause Button was tapped.
    ///
    /// It sets the status to tracking or paused.
    ///
    @objc func trackerButtonTapped() {
        print("startGpxTracking::")
        switch gpxTrackingStatus {
        case .notStarted:
            gpxTrackingStatus = .tracking
        case .tracking:
            gpxTrackingStatus = .paused
        case .paused:
            //set to tracking
            gpxTrackingStatus = .tracking
        }
    }
    
    ///
    /// Triggered when user taps on save Button
    ///
    /// It prompts the user to set a name of the file.
    ///
    @objc func saveButtonTapped() {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        
        // save alert configuration and presentation
        let alertController = UIAlertController(title: "Save as", message: "Enter GPX session name", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.clearButtonMode = .always
            textField.text = self.lastGpxFilename.isEmpty ? self.defaultFilename() : self.lastGpxFilename
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let filename = (alertController.textFields?[0].text!.utf16.count == 0) ? self.defaultFilename() : alertController.textFields?[0].text
            print("Save File \(String(describing: filename))")
            //export to a file
            let gpxString = self.map.exportToGPXString()
            GPXFileManager.save(filename!, gpxContents: gpxString)
            self.lastGpxFilename = filename!
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    ///
    /// There was a memory warning. Right now, it does nothing but to log a line.
    ///
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning");
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///
    /// Checks the location services status
    /// - Are location services enabled (access to location device wide)? If not => displays an alert
    /// - Are location services allowed to this app? If not => displays an alert
    ///
    /// - Seealso: displayLocationServicesDisabledAlert, displayLocationServicesDeniedAlert
    ///
    func checkLocationServicesStatus() {
        //Are location services enabled?
        if !CLLocationManager.locationServicesEnabled() {
            displayLocationServicesDisabledAlert()
            return
        }
        //Does the app have permissions to use the location servies?
        if !([.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())) {
            displayLocationServicesDeniedAlert()
            return
        }
    }
    ///
    /// Displays an alert that informs the user that location services are disabled.
    ///
    /// When location services are disabled is for all applications, not only this one.
    ///
    func displayLocationServicesDisabledAlert() {
        
        let alertController = UIAlertController(title: "Location services disabled", message: "Go to settings and enable location.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    
    ///
    /// Displays an alert that informs the user that access to location was denied for this app (other apps may have access).
    /// It also dispays a button allows the user to go to settings to activate the location.
    ///
    func displayLocationServicesDeniedAlert() {
        if isDisplayingLocationServicesDenied {
            return // display it only once.
        }
        let alertController = UIAlertController(title: "Access to location denied", message: "On Location settings, allow always access to location for GPX Tracker ", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        isDisplayingLocationServicesDenied = false
    }
    
}

// MARK: StopWatchDelegate

///
/// Updates the `timeLabel` with the `stopWatch` elapsedTime.
/// In the main ViewController there is a label that holds the elapsed time, that is, the time that
/// user has been tracking his position.
///
///
extension ViewController: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel.text = elapsedTimeString
    }
}

// MARK: PreferencesTableViewControllerDelegate

extension ViewController: PreferencesTableViewControllerDelegate {
    ///
    /// Updates the `tileServer` the map is using.
    ///
    /// If user enters preferences and he changes his preferences regarding the `tileServer`,
    /// the map of the main `ViewController` needs to be aware of it.
    ///
    /// `PreferencesTableViewController` informs the main `ViewController` through this delegate.
    ///
    func didUpdateTileServer(_ newGpxTileServer: Int) {
        print("PreferencesTableViewControllerDelegate:: didUpdateTileServer: \(newGpxTileServer)")
        self.map.tileServer = GPXTileServer(rawValue: newGpxTileServer)!
    }
    
    ///
    /// If user changed the setting of using cache, through this delegate, the main `ViewController`
    /// informs the map to behave accordingly.
    ///
    func didUpdateUseCache(_ newUseCache: Bool) {
        print("PreferencesTableViewControllerDelegate:: didUpdateUseCache: \(newUseCache)")
        self.map.useCache = newUseCache
    }
    
    // User changed the setting of use imperial units.
    func didUpdateUseImperial(_ newUseImperial: Bool) {
        print("PreferencesTableViewControllerDelegate:: didUpdateUseImperial: \(newUseImperial)")
        useImperial = newUseImperial
        totalTrackedDistanceLabel.useImperial = useImperial
        currentSegmentDistanceLabel.useImperial = useImperial
        //Because we dont know if last speed was unknown we set it as unknown.
        // In regular circunstances it will go to the new units relatively fast.
        speedLabel.text = kUnknownSpeedText
        signalAccuracyLabel.text = kUnknownAccuracyText
    }}

// MARK: location manager Delegate

/// Extends `ViewController`` to support `GPXFilesTableViewControllerDelegate` function
/// that loads into the map a the file selected by the user.
extension ViewController: GPXFilesTableViewControllerDelegate {
    ///
    /// Loads the selected GPX File into the map.
    ///
    /// Resets whatever estatus was before.
    ///
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot) {
        //emulate a reset button tap
        self.resetButtonTapped()
        //println("Loaded GPX file", gpx.gpx())
        lastGpxFilename = gpxFilename
        //force reset timer just in case reset does not do it
        self.stopWatch.reset()
        //load data
        self.map.importFromGPXRoot(gpxRoot)
        //stop following user
        self.followUser = false
        //center map in GPX data
        self.map.regionToGPXExtent()
        self.gpxTrackingStatus = .paused
        
        self.totalTrackedDistanceLabel.distance = self.map.session.totalTrackedDistance
        
    }
}

// MARK: CLLocationManagerDelegate

// Extends view controller to support Location Manager delegate protocol
extension ViewController: CLLocationManagerDelegate {
    
    /// Location manager calls this func to inform there was an error.
    ///
    /// It performs the following actions:
    ///  - Sets coordsLabel with `kNotGettingLocationText`, signal accuracy to
    ///    kUnknownAccuracyText and signalImageView to signalImage0.
    ///  - If the error code is `CLError.denied` it calls `checkLocationServicesStatus`
    
    ///
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        coordsLabel.text = kNotGettingLocationText
        signalAccuracyLabel.text = kUnknownAccuracyText
        signalImageView.image = signalImage0
        let locationError = error as? CLError
        switch locationError?.code {
        case CLError.locationUnknown:
            print("Location Unknown")
        case CLError.denied:
            print("Access to location services denied. Display message")
            checkLocationServicesStatus()
        case CLError.headingFailure:
            print("Heading failure")
        default:
            print("Default error")
        }
        
    }
    
    ///
    /// Updates location accuracy and map information when user is in a new position
    ///
    ///
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //updates signal image accuracy
        let newLocation = locations.first!
        print("isUserLocationVisible: \(map.isUserLocationVisible) showUserLocation: \(map.showsUserLocation)")
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(newLocation.horizontalAccuracy) vAcc: \(newLocation.verticalAccuracy) floor: \(newLocation.floor?.description ?? "''") map.userTrackingMode: \(map.userTrackingMode.rawValue)")
        
        // Update horizontal accuracy
        let hAcc = newLocation.horizontalAccuracy
        signalAccuracyLabel.text =  hAcc.toAccuracy(useImperial: useImperial)
        if hAcc < kSignalAccuracy6 {
            self.signalImageView.image = signalImage6
        } else if hAcc < kSignalAccuracy5 {
            self.signalImageView.image = signalImage5
        } else if hAcc < kSignalAccuracy4 {
            self.signalImageView.image = signalImage4
        } else if hAcc < kSignalAccuracy3 {
            self.signalImageView.image = signalImage3
        } else if hAcc < kSignalAccuracy2 {
            self.signalImageView.image = signalImage2
        } else if hAcc < kSignalAccuracy1 {
            self.signalImageView.image = signalImage1
        } else{
            self.signalImageView.image = signalImage0
        }
        
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        coordsLabel.text = "(\(latFormat),\(lonFormat)) · altitude: \(newLocation.altitude.toAltitude(useImperial: useImperial))"
        
        //Update speed
        speedLabel.text = (newLocation.speed < 0) ? kUnknownSpeedText : newLocation.speed.toSpeed(useImperial: useImperial)
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.distance = map.session.totalTrackedDistance
            currentSegmentDistanceLabel.distance = map.session.currentSegmentDistance
        }
    }
    
    
    ///
    ///
    /// When there is a change on the heading (direction in which the device oriented) it makes a request to the map
    /// to updathe the heading indicator (a small arrow next to user location point)
    ///
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("ViewController::didUpdateHeading \(newHeading.trueHeading)")
        map.updateHeading(newHeading)
        
    }
}




