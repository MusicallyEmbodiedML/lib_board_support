#include "audio_app.h"

extern "C" {
    #include <xcore/channel_streaming.h>
    #include <string.h>
    #include <stdio.h>
}

template<typename T>
void clear_buffer(T *buffer, size_t length) {
    memset(buffer, 0, sizeof(T)*length);
}


void audio_app_init(chanend_t i2s_audio_out) {
}


void audio_loop(chanend_t i2s_audio_in, chanend_t i2s_audio_out)
{
    int32_t __attribute__((aligned (8))) zerobuf [2*kAudioSamples][kAudioChannels];
    clear_buffer(zerobuf, 2*kAudioBufferLength);
    // Provide twice the data to i2s buffer
    s_chan_out_buf_word(i2s_audio_out, (uint32_t*) zerobuf, 2*kAudioBufferLength);
    printf("Audio app buffers initialised.\n");

    int32_t __attribute__((aligned (8))) input [kAudioSamples][kAudioChannels];
    clear_buffer(input, kAudioBufferLength);

    while (1) {
        //s_chan_in_buf_word(i2s_audio_in, (uint32_t*) input, kAudioBufferLength);
        // Process the data here!
        //s_chan_out_buf_word(i2s_audio_out, (uint32_t*) input, kAudioBufferLength);
    }
}
