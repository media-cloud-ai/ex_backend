
import {Component, ViewChild, Output, EventEmitter} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {Link, LinkLabels} from '../models/person';

@Component({
  selector: 'link-import-component',
  templateUrl: 'link_import.component.html',
  styleUrls: ['./link_import.component.less'],
})

export class PersonLinkImportComponent {

  error_message: string = "";
  link: Link = new Link();

  @Output() onUrlSet = new EventEmitter<Link>();

  links: Link[] = [
    { label: LinkLabels.imdb, url: "" },
  ];

  checkUrl(link_label: string, link_url: string): void {
    this.error_message = "";
    this.link.url = "";

    switch(link_label) {
      case LinkLabels.imdb:
        if(link_url.search(/https:\/\/www.imdb.com\/name\/nm[0-9]{7}\/.*/) >= 0) {
          this.link.url = link_url.replace("https://www.imdb.com/name/", "").split("/")[0];
        } else if(link_url.search(/nm[0-9]{7}/) >= 0) {
          this.link.url = link_url;
        }
        break;

      default:
        this.error_message = "Unsupported link label: " + link_label;
        break;
    }

    if(this.link.url == "") {
      this.error_message = "Invalid URL";
      return;
    }

    this.link.label = link_label;
    // console.log("Link:", this.link);
    this.onUrlSet.emit(this.link);
  }

}
