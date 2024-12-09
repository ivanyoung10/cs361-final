#!/usr/bin/env ruby

class Track
  def initialize(segments, title=nil)
    @title = title
    segment_objects = []

    segments.each do |segment|
      segment_objects.append(TrackSegment.new(segment))
    end

    # set segments to segment_objects
    @segments = segment_objects
  end

  def get_track_json()
    # json variable to hold all of the information
    json = ''
    
    json += '{'

    json += '"type": "Feature", '
    json += '"properties": {'
    json += '"title": "' + @title + '"'

    json += '},'

    json += '"geometry": {'
    json += '"type": "MultiLineString",'

    json +='"coordinates": ['
    @segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end

      json += '['
      coord_json = ''

      segment.coordinates.each do |coordinate|
        if coord_json != ''
          coord_json += ','
        end

        # Add the coordinate
        coord_json += '['
        coord_json += "#{coordinate.longitude},#{coordinate.latitude}"

        if coordinate.elevation != nil
          coord_json += ",#{coordinate.elevation}"
        end

        coord_json += ']'
      end

      json += coord_json
      json += ']'
    end

    json + ']}}'
  end

end


class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

end


class Waypoint
  attr_reader :latitude, :longitude, :elevation, :name, :type

  def initialize(longitude, latitude, ele=nil, name=nil, type=nil)
    @latitude = latitude
    @longitude = longitude
    @elevation = elevation
    @name = name
    @type = type
  end

  def get_waypoint_json()
    json = '{"type": "Feature",'
    json += '"geometry": {"type": "Point","coordinates": '
    json += "[#{@longitude},#{@latitude}"

    # only adds elevation, if elevation is given
    if elevation != nil
      json += ",#{@elevation}"
    end

    json += ']},'

    if name != nil or type != nil
      json += '"properties": {'

      if name != nil
        json += '"title": "' + @name + '"'
      end

      if type != nil
        if name != nil
          json += ','
        end

        json += '"icon": "' + @type + '"'
      end

      json += '}'
    end

    json += "}"

    return json
  end

end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson()
    feature_json = '{"type": "FeatureCollection","features": ['

    @features.each_with_index do |feature, index|
      if index != 0
        feature_json += ","
      end

      if feature.class == Track
          feature_json += feature.get_track_json
      elsif feature.class == Waypoint
          feature_json += feature.get_waypoint_json
      end

    end
    feature_json + "]}"
  end

end

def main()
  waypoint1 = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  
  waypoint_set1 = [
  Waypoint.new(-122, 45),
  Waypoint.new(-122, 46),
  Waypoint.new(-121, 46),
  ]

  waypoint_set2  = [
     Waypoint.new(-121, 45), 
     Waypoint.new(-121, 46), 
  ]

  waypoint_set3 = [
    Waypoint.new(-121, 45.5),
    Waypoint.new(-122, 45.5),
  ]

  track1 = Track.new([waypoint_set1, waypoint_set2], "track 1")
  track2 = Track.new([waypoint_set3], "track 2")

  world = World.new("My Data", [waypoint1, waypoint2, track1, track2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

