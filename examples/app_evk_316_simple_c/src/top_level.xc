// Copyright 2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#include <platform.h>
#include <xs1.h>
#include "i2s.h"
#include <stdio.h>

#include "audio_app.h"
#include "codec_setup.h"

#ifndef XMOS_I2S_MASTER
#define XMOS_I2S_MASTER         1
#endif


// I2S resources
on tile[1]: in port p_mclk =                                PORT_MCLK_IN;
on tile[1]: buffered out port:32 p_lrclk =                  PORT_I2S_LRCLK;
on tile[1]: out port p_bclk =                               PORT_I2S_BCLK;
on tile[1]: buffered out port:32 p_dac[NUM_I2S_LINES] =     {PORT_I2S_DAC_DATA};
on tile[1]: buffered in port:32 p_adc[NUM_I2S_LINES] =      {PORT_I2S_ADC_DATA};
on tile[1]: clock bclk =                                    XS1_CLKBLK_1;


extern void tile_0_main(chanend c);
extern void tile_1_main(chanend c);
extern void audio_loop(streaming chanend, streaming chanend);
extern void audio_app_init(streaming chanend);

void i2s_loopback(server i2s_frame_callback_if i_i2s, streaming chanend audio_in, streaming chanend audio_out)
{
    int32_t samples[NUM_I2S_LINES * CHANS_PER_FRAME] = {0}; // Array used for looping back samples
    uint32_t counter = 0;
    int32_t throwaway_buf[32] = {0};

    for (unsigned int n = 0; n < 32; n++) {
        audio_out :> throwaway_buf[n];
    }

    while (1) {
    select {
        case i_i2s.init(i2s_config_t &?i2s_config, tdm_config_t &?tdm_config):
            i2s_config.mode = I2S_MODE_I2S;
            i2s_config.mclk_bclk_ratio = (MASTER_CLOCK_FREQUENCY / (SAMPLE_FREQUENCY * CHANS_PER_FRAME * DATA_BITS));
            break;

        case i_i2s.receive(size_t n_chans, int32_t in_samps[n_chans]):
            for (int i = 0; i < n_chans; i++){
                samples[i] = in_samps[i]; // copy samples
                //audio_in <: samples[i];
            }
            if (counter++ >= 48000) {
                printf(".\n");
                counter = 0;
            }
            break;

        case i_i2s.send(size_t n_chans, int32_t out_samps[n_chans]):
            for (int i = 0; i < n_chans; i++){
                //audio_out :> samples[i];
                out_samps[i] = samples[i]; // copy samples
            }
            break;

        case i_i2s.restart_check() -> i2s_restart_t restart:
            restart = I2S_NO_RESTART; // Keep on looping
            break;
        }
    }
}

int main(void){
    chan c;
    par{
        on tile[0]: tile_0_main(c);
        on tile[1]: {
            interface i2s_frame_callback_if i_i2s;
            streaming chan audio_in, audio_out;
            tile_1_main(c);
            audio_app_init(audio_out);
            par {
                audio_loop(audio_in, audio_out);
                i2s_loopback(i_i2s, audio_in, audio_out);
                i2s_frame_master(i_i2s, p_dac, NUM_I2S_LINES, p_adc, NUM_I2S_LINES, DATA_BITS, p_bclk, p_lrclk, p_mclk, bclk);
            }
        }
    }

    return 0;
}
