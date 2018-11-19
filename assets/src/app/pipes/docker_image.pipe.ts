import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | dockerImage
 * Example:
 *   {{ 'ftvsubtil/http_worker:latest' | dockerImage }}
 *   formats to: "HTTP Worker"
*/
@Pipe({name: 'dockerImage'})
export class DockerImagePipe implements PipeTransform {
  transform(image_name: string): string {
    var allDockerImages = [
      { id: 'ftvsubtil/backend', name: 'Backend' },
      { id: 'ftvsubtil/acs_worker', name: 'ACS Worker' },
      { id: 'ftvsubtil/ffmpeg_worker', name: 'FFmpeg Worker' },
      { id: 'ftvsubtil/file_system_worker', name: 'File System Worker' },
      { id: 'ftvsubtil/ftp_worker', name: 'FTP Worker' },
      { id: 'ftvsubtil/gpac_worker', name: 'GPAC Worker' },
      { id: 'ftvsubtil/http_worker', name: 'HTTP Worker' },
      { id: 'ftvsubtil/rdf_worker', name: 'RDF Worker' },
      { id: 'postgres', name: 'PostgreSQL' },
      { id: 'rabbitmq', name: 'RabbitMQ' },
    ]

    for (var i = allDockerImages.length - 1; i >= 0; i--) {
      if (allDockerImages[i].id === image_name.split(':')[0]){
        return allDockerImages[i].name
      }
    }
    return image_name
  }
}
