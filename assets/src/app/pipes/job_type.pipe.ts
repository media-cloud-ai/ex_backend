import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | jobType
 * Example:
 *   {{ 'ftp_order' | jobType }}
 *   formats to: "FTP transfer"
*/
@Pipe({name: 'jobType'})
export class JobTypePipe implements PipeTransform {

  transform(jobType: string): string {
    var allJobType = [
      { id: 'acs_prepare_audio', name: 'ACS: prepare audio' },
      { id: 'acs_synchronize', name: 'Audio Content Synchronisation' },
      { id: 'audio_decode', name: 'ACS: decode audio' },
      { id: 'audio_encode', name: 'ACS: encode audio' },
      { id: 'audio_extraction', name: 'Audio extraction' },
      { id: 'clean_workspace', name: 'Clean workspace' },
      { id: 'copy', name: 'Archive' },
      { id: 'download_ftp', name: 'FTP download' },
      { id: 'download_http', name: 'HTTP download' },
      { id: 'ftp_order', name: 'FTP transfer' },
      { id: 'generate_dash', name: 'Generate DASH' },
      { id: 'gpac_dash', name: 'DASH generation' },
      { id: 'ism_extraction', name: 'ISM extraction' },
      { id: 'ism_manifest', name: 'ISM manifest'},
      { id: 'set_language', name: 'Language setting' },
      { id: 'speech_to_text', name: 'Speech to Text' },
      { id: 'ttml_to_mp4', name: 'TTML to MP4' },
      { id: 'upload_file', name: 'Upload File' },
      { id: 'upload_ftp', name: 'FTP upload' },
      { id: 'push_rdf', name: 'Push RDF' },
    ]

    for (var i = allJobType.length - 1; i >= 0; i--) {
      if (allJobType[i].id === jobType){
        return allJobType[i].name
      }
    }
    return jobType
  }
}
