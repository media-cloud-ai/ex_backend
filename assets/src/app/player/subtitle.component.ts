
import {Component, Input, OnChanges, SimpleChange} from '@angular/core';
import {HttpClient} from '@angular/common/http';

import * as sax from 'sax';
import {
  fromXML,
  generateISD,
  renderHTML,
  } from 'imsc';

@Component({
  selector: 'subtitle-component',
  templateUrl: 'subtitle.component.html',
  styleUrls: ['./subtitle.component.less'],
})

export class SubtitleComponent implements OnChanges {
  @Input() content_id: string;
  @Input() language: string;
  @Input() time: number;

  original : string;

  tt = null;
  isd = null;

  constructor(
    private http: HttpClient,
  ) {}

  ngOnInit() {
    var subtitle_url = "/stream/" + this.content_id + "/" + this.language + ".ttml";
    this.http.get(subtitle_url, {responseType: 'text'})
    .subscribe(contents => {
      this.original = contents;
      this.tt = fromXML(contents.replace(/\r\n/g, '\n'), this.errorHandler);
      this.refresh(1);
      console.log(this.tt);
      this.changeText(this.time, "hum, bienvenue au nom de l'équipe", "Welcome Dude ;-)");
    });
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    if(changes && changes.time) {
      this.refresh(changes.time.currentValue);
    }
  }

  refresh(time) {
    if(this.tt){
      this.isd = generateISD(this.tt, time, this.errorHandler);
      // console.log(this.isd);
    }
  }

  changeText(time: number, old_content: string, new_content: string) {
    console.log(time, old_content, new_content);
    var parser = new DOMParser();
    var xmlDoc = parser.parseFromString(this.original, "text/xml");
    var paragraphs = xmlDoc.getElementsByTagName("p");
    for(var i = 0; i < paragraphs.length; ++i) {
      // @TODO check if time is between begin and end
      // console.log(paragraphs[i].getAttribute("begin"));
      // console.log(paragraphs[i].getAttribute("end"));
      var spans = paragraphs[i].getElementsByTagName("span");
      for(var j = 0; j < spans.length; ++j) {
        if(spans[j].childNodes[0].nodeValue == old_content){
          spans[j].childNodes[0].nodeValue = new_content;
        }
      }
    }

    var serializer = new XMLSerializer();
    var xml = serializer.serializeToString(xmlDoc);
    this.tt = fromXML(xml.replace(/\r\n/g, '\n'), this.errorHandler);
    this.refresh(this.time);
  }

  errorHandler = {
    info: function (msg) {
        console.log("info: " + msg);
        return false;
    },
    warn: function (msg) {
        console.log("warn: " + msg);
        return false;
    },
    error: function (msg) {
        console.log("error: " + msg);
        return false;
    },
    fatal: function (msg) {
        console.log("fatal: " + msg);
        return false;
    }
  };
}
