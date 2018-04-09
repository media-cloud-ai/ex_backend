import { Pipe, PipeTransform } from '@angular/core';
/*
 * Usage:
 *   value | iconForJob
 * Example:
 *   {{ 'download_ftp' | iconForJob }}
 *   formats to: "file_download"
*/
@Pipe({name: 'iconForJob'})
export class IconForJobPipe implements PipeTransform {

  transform(iconForJob: string): string {
    var allJobIcons = [
      { id: 'acs_prepare_audio', name: 'music_video' },
      { id: 'acs_synchronize', name: 'music_video' },
      { id: 'audio_decode', name: 'music_video' },
      { id: 'audio_encode', name: 'music_video' },
      { id: 'audio_extraction', name: 'queue_music' },
      { id: 'clean_workspace', name: 'delete_forever' },
      { id: 'download_ftp', name: 'file_download' },
      { id: 'download_http', name: 'file_download' },
      { id: 'generate_dash', name: 'tv' },
      { id: 'set_language', name: 'speaker_notes' },
      { id: 'ttml_to_mp4', name: 'closed_caption' },
      { id: 'upload_ftp', name: 'file_upload' },
    ];

    for (var i = allJobIcons.length - 1; i >= 0; i--) {
      if(allJobIcons[i].id == iconForJob){
        return allJobIcons[i].name;
      }
    }
    return "settings";
  }
}
