#ifndef __AUDIO_APP_H__
#define __AUDIO_APP_H__


#define kAudioChannels    2
#define kAudioSamples    8
#define kAudioBufferLength    (kAudioChannels*kAudioSamples)

#if !defined(__XC__)

#if __cplusplus
extern "C" {
#endif

#include <xcore/chanend.h>


extern void audio_app_init(chanend_t i2s_audio_out);
extern void audio_loop(chanend_t i2s_audio_in, chanend_t i2s_audio_out);

#if __cplusplus
}
#endif

#endif  // __XC__

#endif  // __AUDIO_APP_H__