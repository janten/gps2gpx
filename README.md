gps2gpx
=======
Convert gps files from [getgps](http://github.com/janten/getgps) to GPX format.

Usage
=====
gps2gpx can only convert one file at a time with `gps2gpx filename`. It will create a gpx file of the same name containing one track with one more track segments. A new segment is started if two sequential log points are too distant to each other in time or space.
