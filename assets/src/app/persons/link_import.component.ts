
import {Component, EventEmitter, Input, Output, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {IMDbService} from '../services/imdb.service';
import {LinkLabel, Links} from '../models/person';

@Component({
  selector: 'link-import-component',
  templateUrl: 'link_import.component.html',
  styleUrls: ['./link_import.component.less'],
})

export class LinkImportComponent {

  @Input() type: string;
  loading: boolean = false; 
  error_message: string = "";
  autocomplete: any;
  selected: any;
  label: LinkLabel;

  @Output() onUrlSet = new EventEmitter<Links>();

  constructor(
    private imdbService: IMDbService,
  ) {}

  ngOnInit() {
    if(this.type == "imdb") {
      this.label = LinkLabel.imdb;
    }
    if(this.type == "linkedin") {
      this.label = LinkLabel.linkedin;
    }
    if(this.type == "facebook") {
      this.label = LinkLabel.facebook;
    }
  }

  searchImdb(text: string): void {
    this.imdbService.search(text)
    .subscribe(response => {
      this.autocomplete = response;
    });
  }

  selectUser(user_id: string) {
    let links = new Links;
    links.imdb = user_id;
    this.onUrlSet.emit(links);
  }
}
