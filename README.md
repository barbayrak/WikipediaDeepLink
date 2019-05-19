# WikipediaDeepLink
In order to work you need to download and run both this app and forked version of Wikipedia app that i changed from below
<br/>
You can get the forked Wikipedia app i worked on from [here](https://github.com/barbayrak/wikipedia-ios)

## What this app is doing ?
This app is basically doing a location search based on the text you provide from Apple's MapKit location API and creates
an appropriate deeplink for Wikipedia app in order to redirect.
<br/>
Here is the code that generates deeplink when you tap on a location:
```swift
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = "wikipedia://places?lat=\(self.locations[indexPath.row].latitude)&lon=\(self.locations[indexPath.row].longtitude)"
        guard let url = URL(string: urlString) else { return }
        
        if(UIApplication.shared.canOpenURL(url)){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            let alert = UIAlertController(title: "Not Found", message: "No Wikipedia app found on this device. Please check that you have Wikipedia app installed on this device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
```
## What i changed in Wikipedia app for this functionality ?

In order to make the places deeplink first i need to change the NSUserActivity extension for parsing the url

Here is the changes that i made in NSUserActivity+WMFExtension.m :
```objective-c
+ (instancetype)wmf_placesActivityWithURL:(NSURL *)activityURL {
    NSURLComponents *components = [NSURLComponents componentsWithURL:activityURL resolvingAgainstBaseURL:NO];
    NSURL *articleURL = nil;
    NSNumber *latitude = nil;
    NSNumber *longtitude = nil;
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"WMFArticleURL"]) {
            NSString *articleURLString = item.value;
            articleURL = [NSURL URLWithString:articleURLString];
        }else if([item.name isEqualToString:@"lat"]){
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            latitude = [formatter numberFromString:item.value];
        }else if([item.name isEqualToString:@"lon"]){
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            longtitude = [formatter numberFromString:item.value];
        }
    }
    NSUserActivity *activity = [self wmf_pageActivityWithName:@"Places"];
    
    NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] initWithDictionary:activity.userInfo];
    if (latitude && longtitude) {
        [userInfoDic setObject:latitude forKey:@"lat"];
        [userInfoDic setObject:longtitude forKey:@"lon"];
    }
    activity.userInfo = userInfoDic;
    
    activity.webpageURL = articleURL;
    return activity;
}
```

After this i need to get the parsed values in processUserActivity function which is fired from AppDelegate's open url function

WMFAppViewController.m :
```objective-c
case WMFUserActivityTypePlaces: {
            [self setSelectedIndex:WMFAppTabTypePlaces];
            [self.navigationController popToRootViewControllerAnimated:animated];
            NSURL *articleURL = activity.wmf_articleURL;
            NSNumber *lat = activity.wmf_lat;
            NSNumber *lon = activity.wmf_lon;
            if (articleURL) {
                // For "View on a map" action to succeed, view mode has to be set to map.
                [[self placesViewController] updateViewModeToMap];
                [[self placesViewController] showArticleURL:articleURL];
            }else if(lat && lon) {
                [[self placesViewController] updateViewModeToMap];
                [[self placesViewController] showLocationWithLatitude:lat longtitude:lon];
            }
        }
```

In the end i need to add the showLocation function for PlacesViewController.swift in order to directly zoom that location without tracing your current location

PlacesViewController.swift
```swift
    @objc public func showLocation(latitude : NSNumber,longtitude : NSNumber){
        locationManager.stopMonitoringLocation()
        zoomAndPanMapView(toLocation: CLLocation(latitude: latitude.doubleValue, longitude: longtitude.doubleValue));
    }
```

# Unit Tests
There needs to be 2 steps for unit tests here, one for this app and one for Wikipedia app in order to fully test deep link from one app to another.

Unit tests in Wikipedia app that i wrote : 

```objective-c
- (void)testPlacesURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=10.2&lon=-5.8"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.wmf_lat, [NSNumber numberWithDouble:10.2]);
    XCTAssertEqualObjects(activity.wmf_lon, [NSNumber numberWithDouble:-5.8]);
}
    
- (void)testPlacesInvalidLatAndLon {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=10.2"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.wmf_lat);
    XCTAssertNil(activity.wmf_lon);
}
```

Unit tests in this app :

```swift

```


