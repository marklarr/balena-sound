class PianobarEvent
  def initialize(parsed_json, event_type, artist, title, album, cover_art_img_url)
    @event_type = event_type
    @artist = artist
    @title = title
    @album = album
    @cover_art_img_url = cover_art_img_url
  end

  def self.from_parsed_json(parsed_json)
    event_type = parsed_json['event_type']
    artist = parsed_json['artist']
    title = parsed_json['title']
    album = parsed_json['album']
    cover_art_img_url = parsed_json['coverArt']
    new(parsed_json, event_type, artist, title, album, cover_art_img_url)
  end

  def get_status
    "#{@artist} - #{@title} (#{@event_type})"
  end
end
