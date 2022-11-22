import { Component } from '@angular/core'
import { ActivatedRoute } from '@angular/router'

import { Registery, Subtitle } from '../models/registery'
import { RegisteryService } from '../services/registery.service'

import { MediaPlayer } from 'dashjs'

@Component({
  selector: 'registery_detail-component',
  templateUrl: 'registery_detail.component.html',
  styleUrls: ['./registery_detail.component.less'],
})
export class RegisteryDetailComponent {
  private sub: any
  private registery_id: number
  private registery: Registery
  private root: Subtitle[]

  player = MediaPlayer().create()

  constructor(
    private registeryService: RegisteryService,
    private route: ActivatedRoute,
  ) {}

  ngOnInit() {
    this.sub = this.route.params.subscribe((params) => {
      this.registery_id = +params['id']
      this.getRegistery(this.registery_id)
    })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getRegistery(registery_id): void {
    this.registeryService.getRegistery(registery_id).subscribe((registery) => {
      if (registery === undefined) {
        this.registery = undefined
        return
      }

      this.registery = registery.data
      this.buildGraph()

      if (
        this.registery.params.manifests &&
        this.registery.params.manifests.length > 0 &&
        this.registery.params.manifests[0].paths &&
        this.registery.params.manifests[0].paths.length > 0
      ) {
        const videoPlayer = document.querySelectorAll('.videoPlayer')[0]
        const url = this.registery.params.manifests[0].paths[0].replace(
          '/dash',
          '/stream',
        )

        this.player.getDebug().setLogToBrowserConsole(false)
        this.player.initialize(<HTMLElement>videoPlayer, url, false)
      }
    })
  }

  buildGraph() {
    if (this.registery === undefined) {
      return
    }

    this.root = []

    for (const subtitle of this.registery.params.subtitles) {
      if (subtitle.parent_id == undefined) {
        const childs = this.getSubtitlesForParent(subtitle.id)
        subtitle.sub_childs = childs
        this.root.push(subtitle)
      }
    }
    console.log('ROOT ', this.root)
  }

  getSubtitlesForParent(parent_id: number): Subtitle[] {
    const list = []
    for (const subtitle of this.registery.params.subtitles) {
      if (subtitle.parent_id === parent_id) {
        const childs = this.getSubtitlesForParent(subtitle.id)
        subtitle.sub_childs = childs
        list.push(subtitle)
      }
    }
    return list
  }
}
