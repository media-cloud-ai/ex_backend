import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | parameterLabel
 * Example:
 *   {{ 'segment_duration' | parameterLabel }}
 *   formats to: "Segment Duration"
 */
@Pipe({ name: 'parameterLabel' })
export class ParameterLabelPipe implements PipeTransform {
  transform(parameterLabel: string): string {
    const allLabels = [
      { id: 'source_paths', name: 'Source Paths' },
      { id: 'source_hostname', name: 'Source Hostname' },
      { id: 'source_username', name: 'Source Username' },
      { id: 'source_password', name: 'Source Password' },
      { id: 'source_prefix', name: 'Source Prefix' },
      { id: 'destination_paths', name: 'Destination Paths' },
      { id: 'destination_hostname', name: 'Destination Hostname' },
      { id: 'destination_username', name: 'Destination Username' },
      { id: 'destination_password', name: 'Destination Password' },
      { id: 'destination_prefix', name: 'Destination Prefix' },
      { id: 'destination_pattern', name: 'Destination Pattern' },

      { id: 'segment_duration', name: 'Segment Duration' },
      { id: 'fragment_duration', name: 'Fragment Duration' },
      { id: 'audio_track', name: 'Audio track' },
      { id: 'text_track', name: 'Text track' },
      { id: 'threads_number', name: 'Threads number' },
      { id: 'keep_original', name: 'Keep original' },

      { id: 'input_filter', name: 'Input filter' },

      { id: 'input_codec_audio', name: 'Audio input codec' },
      { id: 'output_codec_audio', name: 'Audio output codec' },
      { id: 'input_codec_video', name: 'Video input codec' },
      { id: 'output_codec_video', name: 'Video output codec' },
      { id: 'disable_video', name: 'Disable video' },
      { id: 'disable_audio', name: 'Disable audio' },
      { id: 'disable_data', name: 'Disable data' },
      { id: 'audio_sampling_rate', name: 'Audio sampling rate' },
      { id: 'audio_channels', name: 'Audio channels' },

      { id: 'force_overwrite', name: 'Force Overwrite' },
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

      { id: 'perfect_memory_username', name: 'Perfect-Memory Username' },
      { id: 'perfect_memory_password', name: 'Perfect-Memory Password' },
    ]

    for (let i = allLabels.length - 1; i >= 0; i--) {
      if (allLabels[i].id === parameterLabel) {
        return allLabels[i].name
      }
    }
    return parameterLabel
  }
}
