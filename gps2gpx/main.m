//
//  main.m
//  gps2gpx
//
//  Created by Jan-Gerd Tenberge on 04.09.12.
//  Copyright (c) 2012 Jan-Gerd Tenberge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "NSDate+SSToolkitAdditions.h"

double deg2rad(double deg) {
    return (deg * M_PI / 180.0);
}

double rad2deg(double rad) {
    return (rad / M_PI * 180.0);
}

double distance(double lat1, double lon1, double lat2, double lon2) {
    //code for Distance in Kilo Meter
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = abs(round(rad2deg(acos(dist)) * 60 * 1.1515 * 1.609344 * 1000));
    return (dist);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            NSLog(@"No filename given");
            return 0;
        }
        for (int i = 1; i<argc; i++) {
            NSString *filename = [NSString stringWithUTF8String:argv[i]];
            NSMutableString *gpxString = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\n<gpx version=\"1.1\" creator=\"Jan-Gerd Tenberge\">\n<trk>\n<trkseg>\n"];
            NSData *gpsData = [NSData dataWithContentsOfFile:filename];
            char stopData[2] = {0x00, 0x2a};
            NSData *delimiter = [NSData dataWithBytes:stopData length:2];
            NSLog(@"Read %li bytes of data", gpsData.length);
            unsigned long start = 0;
            double lat, lon;
            int32_t timestamp = 0;
            int32_t oldTimestamp;
            while (start < gpsData.length) {
                NSRange foundRange = [gpsData rangeOfData:delimiter options:0 range:NSMakeRange(start, gpsData.length-start)];
                if (foundRange.location == NSNotFound) {
                    break;
                }
                start = foundRange.location;
                oldTimestamp = timestamp;
                timestamp = *(int*)(gpsData.bytes+start + 3);
                int16_t checksum = *(int16_t*)(gpsData.bytes+start + 7);
                lat = *(double*)(gpsData.bytes+start + 9);
                lon = *(double*)(gpsData.bytes+start + 17);
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
                
                if ((checksum == 2) && ((lat > 0.001) || (lat < -0.001)) && ((lon > 0.001) || (lon < -0.001)) && (lat < 180) && (lat > -180) && (lon < 180) && (lon > -180)) {
                    if (oldTimestamp && (abs(oldTimestamp - timestamp) > 60)) {
                        [gpxString appendString:@"</trkseg></trk>\n<trk><trkseg>\n"];
                    }
                    [gpxString appendFormat:@"<trkpt lat=\"%f\" lon=\"%f\">\n\t<time>%@</time>\n</trkpt>\n", lat, lon, date.ISO8601String];
                }
                start++;
            }
            
            [gpxString appendString:@"</trkseg>\n</trk>\n</gpx>"];
            [gpxString writeToFile:[[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"gpx"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"File %@ converted", filename);
        }
    }
    return 0;
}

