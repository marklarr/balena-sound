require 'pandora_client'

deviceModel = 'android-generic'
username = 'android'
password = 'AC7IBG09A3DTSYM4R41UJWL07VLN8JI7'
encryptKey = '6#26FRL$ZWD'
decryptKey = 'R=U!LH$O2B#'


partner = Pandora::Partner.new(username, password, deviceModel, encryptKey, decryptKey)

username = 'larse503@gmail.com'

print 'Password: '
password = gets.chomp

user = partner.login_user(username, password)

station = user.stations.first

while true
	next_songs = station.next_songs

	next_songs.each do |song|
    audio_url = song.audio_urls['HTTP_64_AACPLUS_ADTS']
    puts audio_url
	end
end
