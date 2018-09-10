import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | parameterLabel
 * Example:
 *   {{ 'segment_duration' | parameterLabel }}
 *   formats to: "Segment Duration"
*/
@Pipe({name: 'parameterLabel'})
export class ParameterLabelPipe implements PipeTransform {

  transform(parameterLabel: string): string {
    var allLabels = [
      { id: 'segment_duration', name: 'Segment Duration' },
      { id: 'fragment_duration', name: 'Fragment Duration' },
      { id: 'audio_track', name: 'Audio track' },
      { id: 'text_track', name: 'Text track' },
      { id: 'threads_number', name: 'Threads number' },
      { id: 'keep_original', name: 'Keep original' },

      { id: 'input_codec_audio', name: 'Audio input codec' },
      { id: 'output_codec_audio', name: 'Audio output codec' },
      { id: 'input_codec_video', name: 'Video input codec' },
      { id: 'output_codec_video', name: 'Video output codec' },
      { id: 'disable_video', name: 'Disable video' },
      { id: 'disable_audio', name: 'Disable audio' },
      { id: 'disable_data', name: 'Disable data' },
      { id: 'audio_sampling_rate', name: 'Audio sampling rate' },
      { id: 'audio_channels', name: 'Audio channels' },

      { id: 'profile_video', name: 'Video profile' },
      { id: 'pixel_format', name: 'Pixel Format' },
      { id: 'colorspace', name: 'Colorspace' },
      { id: 'color_trc', name: 'Color Transfer Characteristics' },
      { id: 'color_primaries', name: 'Color Primaries' },
      { id: 'max_bitrate', name: 'Mix Bitrate' },
      { id: 'buffer_size', name: 'Buffer Size' },
      { id: 'rc_init_occupancy', name: 'Rate Control init occupancy' },
      { id: 'x264-params', name: 'X.264 Parameters' },
      { id: 'preset', name: 'Preset' },
      { id: 'deblock', name: 'Deblock' },
      { id: 'write_timecode', name: 'Write timecode' },

      { id: 'output_directory', name: 'Output Directory' },
      { id: 'language', name: 'Language' },
      { id: 'format', name: 'Format' },
      { id: 'mode', name: 'Mode' },
    ]

    for (var i = allLabels.length - 1; i >= 0; i--) {
      if (allLabels[i].id === parameterLabel){
        return allLabels[i].name
      }
    }
    return parameterLabel
  }
}
