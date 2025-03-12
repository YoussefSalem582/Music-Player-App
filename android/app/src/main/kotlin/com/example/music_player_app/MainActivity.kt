package com.example.music_player_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.media.AudioManager

class MainActivity : FlutterActivity() {
    override fun onResume() {
        super.onResume()
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.requestAudioFocus(null, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
    }

    override fun onPause() {
        super.onPause()
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.abandonAudioFocus(null)
    }
}