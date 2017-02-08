//
//  ReverseGeocoding.m
//
//  Created by cybergarage on 11/1/16.
//  Copyright © 2016 com.41studio. All rights reserved.
//

#import "ReverseGeocoding.h"

@implementation ReverseGeocoding
+ (void)getCurrentLocationWithCompletion:(void (^)(NSString *route,NSString *neighborhood,NSString *city,NSString *country, NSString *fullAddress))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    BOOL __block responseFromCache = YES;
    
    void (^requestSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *addressDict;
        if ([[responseObject objectForKey:@"results"] count]>0) {
            addressDict = [[responseObject objectForKey:@"results"] objectAtIndex:0];
            //get route
            NSArray *routeArray = [[addressDict objectForKey:@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY types like %@",@"route"]];
            NSDictionary *routeDict;
            NSString *routeName;
            if (routeArray.count>0) {
                routeDict = [routeArray objectAtIndex:0];
                routeName = [routeDict valueForKey:@"long_name"];
            }
            else{
                routeName = @"Unknown";
            }
            
            //get sublocality
            NSArray *subLocalityArray = [[addressDict objectForKey:@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY types like %@",@"sublocality"]];
            if (subLocalityArray.count == 0) {
                subLocalityArray = [[addressDict objectForKey:@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY types like %@",@"administrative_area_level_4"]];
            }
            NSDictionary *subLocalityDict;
            NSString *subLocalityName;
            if (subLocalityArray.count>0) {
                subLocalityDict = [subLocalityArray objectAtIndex:0];
                subLocalityName = [subLocalityDict valueForKey:@"long_name"];
            }
            else{
                subLocalityName = @"Unknown";
            }
            
            //get locality
            NSArray *localityArray = [[addressDict objectForKey:@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY types like %@",@"locality"]];
            if (localityArray.count == 0) {
                localityArray = [[addressDict objectForKey:@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY types like %@",@"administrative_area_level_2"]];
            }
            NSDictionary *localityDict;
            NSString *localityName;
            if (localityArray.count>0) {
                localityDict = [localityArray objectAtIndex:0];
                localityName = [localityDict valueForKey:@"long_name"];
            }
            else{
                localityName = @"Unknown";
            }
            
            //get country
            NSArray *countryArray = [[addressDict objectForKey:@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY types like %@",@"country"]];
            NSDictionary *countryDict;
            NSString *countryName;
            if (countryArray.count>0) {
                countryDict = [countryArray objectAtIndex:0];
                countryName = [countryDict valueForKey:@"long_name"];
            }
            else{
                countryName = @"Unknown";
            }
            
            NSMutableString *addressText = [[NSMutableString alloc]initWithString:@""];
            
            if (![routeName isEqualToString:@"Unknown"]) {
                [addressText appendString:routeName];
            }
            
            if (![subLocalityName isEqualToString:@"Unknown"]) {
                [addressText appendString:@", "];
                [addressText appendString:subLocalityName];
            }
            
            if (![localityName isEqualToString:@"Unknown"]) {
                [addressText appendString:@", "];
                [addressText appendString:localityName];
            }
            
            if (![countryName isEqualToString:@"Unknown"]) {
                [addressText appendString:@", "];
                [addressText appendString:countryName];
            }
            completion(routeName,subLocalityName,localityName,countryName,addressText);
        }
        else{
            completion(@"Unknown",@"Unknown",@"Unknown",@"Unknown",@"Unknown");
        }
    };
    
    void (^requestFailureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(@"Unknown",@"Unknown",@"Unknown",@"Unknown",@"Unknown");
    };
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userLastCoordsLat"] floatValue] == 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"userLastCoordsLong"] floatValue] == 0) {
        completion(@"Unknown",@"Unknown",@"Unknown",@"Unknown",@"Unknown");
        return;
    }
    AFHTTPRequestOperation *operation = [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userLastCoordsLat"],[[NSUserDefaults standardUserDefaults] objectForKey:@"userLastCoordsLong"]]
                                          parameters:nil
                                             success:requestSuccessBlock
                                             failure:requestFailureBlock];
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        responseFromCache = NO;
        return cachedResponse;
    }];
}
@end
