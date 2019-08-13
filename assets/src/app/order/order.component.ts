
import {Component} from '@angular/core'
import {ActivatedRoute} from '@angular/router'

let Evaporate = require('evaporate');
let crypto = require('crypto');

@Component({
  selector: 'order-component',
  templateUrl: 'order.component.html',
  styleUrls: ['./order.component.less'],
})

export class OrderComponent {
  is_new_order: boolean = false
  order_id: number
  mp4_file: any
  ttml_file: any

  constructor(
    private route: ActivatedRoute,
  ) {}

  ngOnInit() {
    this.route
      .params.subscribe(params => {
        if(params['id'] == 'new') {
          this.is_new_order = true
        } else {
          this.order_id = params['id']
        }
      })
  }

  upload() {
    var mp4_file = this.mp4_file.files[0]
    var ttml_file = this.ttml_file.files[0]

    var config = {
      signerUrl: '/api/s3_signer',
      aws_key: 'mediaio',
      bucket: 'subtil',
      aws_url: 'https://s3.media-io.com',
      computeContentMd5: true,
      cryptoMd5Method: function (data) {
        console.log(data, crypto.createHash('md5'))
        var buffer = new Buffer(data)
        return crypto.createHash('md5').update(buffer).digest('base64');
      },
      cryptoHexEncodedHash256: function (data) { return crypto.createHash('sha256').update(data).digest('hex'); },
    };

    var uploader = Evaporate.create(config)
      .then(function (evaporate) {
        var addConfig = {
          name: ttml_file.name,
          file: ttml_file,
          progress: function (progressValue) { console.log('Progress', progressValue); },
          complete: function (_xhr, awsKey) { console.log('Complete!'); },
        }
        var overrides = {
          bucket: 'subtil'
        }

        evaporate.add(addConfig, overrides)
          .then(function (awsObjectKey) {
              console.log('File successfully uploaded to:', awsObjectKey);
          },
          function (reason) {
            console.log('File did not upload sucessfully:', reason);
          })
      })
  }
}
