module SoundEffects
  module EffectName
    VOLUME_CHANGE = :volume_change
    PLAY = :play
    PAUSE = :pause
    SKIP = :skip
  end

  SOUND_EFFECT_ASSETS = {
    EffectName::VOLUME_CHANGE => "assets/jambox_volume_change.mp3",
    EffectName::PLAY => "assets/jambox_on.mp3",
    EffectName::PAUSE => "assets/jambox_off.mp3",
    EffectName::SKIP => "assets/jambox_on.mp3",
  }

  private_constant :SOUND_EFFECT_ASSETS

  def self.play_sound_effect(effect_name, target_snapcast_server)
    _thread do
      ShellUtils.exec(%(/bin/bash -c "PULSE_SERVER=#{target_snapcast_server} ffplay -autoexit -nodisp #{_get_path(effect_name)}"))
    end
  end

  def self._get_path(effect_name)
    raise "Unexpected effect_name: #{effect_name}" unless SOUND_EFFECT_ASSETS.has_key?(effect_name)
    SOUND_EFFECT_ASSETS[effect_name]
  end

  def self._thread(&block)
    Thread.new(&block)
  end
end
