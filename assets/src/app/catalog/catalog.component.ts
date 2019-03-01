
import {Component, ViewChild} from '@angular/core'
import {MatDialog, MatCheckboxModule, MatSnackBar, PageEvent} from '@angular/material'
import {ActivatedRoute, Router} from '@angular/router'
import {FormControl} from '@angular/forms'

import {AuthService} from '../authentication/auth.service'
import {RdfService} from '../services/rdf.service'
import {CatalogService} from '../services/catalog.service'
import {WorkflowService} from '../services/workflow.service'
import {CatalogPage} from '../models/page/catalog_page'
import {Catalog} from '../models/catalog'
import {DateRange} from '../models/date_range'

import {RdfDialogComponent} from './rdf/rdf_dialog.component'
import {WorkflowDialogComponent} from './workflow/workflow_dialog.component'

import * as moment from 'moment'

@Component({
  selector: 'catalog-component',
  templateUrl: 'catalog.component.html',
  styleUrls: ['./catalog.component.less'],
})

export class CatalogComponent {
  technician : boolean
  ftvstudio : boolean

  length = 1000

  pageSize = 10
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  page = 0
  sub = undefined
  loading = true

  searchInput = ''
  videoid = ''

  allChannels = [
    {
      label: "Premium",
      list: [
        {id: 'france-2', label: 'France 2'},
        {id: 'france-3', label: 'France 3'},
        {id: 'france-4', label: 'France 4'},
        {id: 'france-5', label: 'France 5'},
        {id: 'france-o', label: 'France Ô'},
        {id: 'franceinfo', label: 'France Info'},
      ]
    },
    {
      label: "Outre-mer",
      list: [
        {id: 'guadeloupe-1ere', label: 'Guadeloupe 1ère'},
        {id: 'guyane-1ere', label: 'Guyane 1ère'},
        {id: 'martinique-1ere', label: 'Martinique 1ère'},
        {id: 'mayotte-1ere', label: 'Mayotte 1ère'},
        {id: "nouvelle-caledonie-1ere", label: "Nouvelle-Calédonie 1ère"},
        {id: "polynesie-1ere", label: "Polynésie 1ère"},
        {id: "reunion-1ere", label: "Réunion 1ère"},
        {id: "saint-pierre-et-miquelon-1ere", label: "Saint-Pierre et Miquelon 1ère"},
        {id: "wallis-et-futuna-1ere", label: "Wallis et Futuna 1ère"},
      ]
    },
    {
      label: "Région",
      list: [
        {id: "france-3-alpes", label: "france 3 Alpes"},
        {id: "france-3-auvergne", label: "france 3 Auvergne"},
        {id: "france-3-rhone-alpes", label: "france 3 Rhône-Alpes"},
        {id: "france-3-bourgogne", label: "france 3 Bourgogne"},
        {id: "france-3-franche-comte", label: "france 3 Franche-Comté"},
        {id: "france-3-bretagne", label: "france 3 Bretagne"},
        {id: "france-3-centre-val-de-loire", label: "france 3 Centre-Val de Loire"},
        {id: "france-3-corse-via-stella", label: "france 3 Corse Via Stella"},
        {id: "france-3-alsace", label: "france 3 Alsace"},
        {id: "france-3-lorraine", label: "france 3 Lorraine"},
        {id: "france-3-champagne-ardenne", label: "france 3 Champagne-Ardenne"},
        {id: "france-3-nord-pas-de-calais", label: "france 3 Nord Pas-de-Calais"},
        {id: "france-3-picardie", label: "france 3 Picardie"},
        {id: "france-3-haute-normandie", label: "france 3 Haute-Normandie"},
        {id: "france-3-basse-normandie", label: "france 3 Basse-Normandie"},
        {id: "france-3-limousin", label: "france 3 Limousin"},
        {id: "france-3-aquitaine", label: "france 3 Aquitaine"},
        {id: "france-3-poitou-charentes", label: "france 3 Poitou-Charentes"},
        {id: "france-3-midi-pyrenees", label: "france 3 Midi-Pyrénées"},
        {id: "france-3-languedoc-roussillon", label: "france 3 Languedoc-Roussillon"},
        {id: "france-3-paris-ile-de-france", label: "france 3 Paris Ile-de-France"},
        {id: "france-3-pays-de-la-loire", label: "france 3 Pays de la Loire"},
        {id: "france-3-provence-alpes", label: "france 3 Provence Alpes"},
        {id: "france-3-cote-d-azur", label: "france 3 Côte d'Azur"},
      ]
    }
  ]

  allOrders = [
    {
      label: "Ascending",
      list: [
        {id: 'broadcasted_at', label: 'Asc Broadcasting At'},
        {id: 'created_at', label: 'Asc Created At'},
        {id: 'updated_at', label: 'Asc Updated At'},
      ]
    },
    {
      label: "Descending",
      list: [
        {id: '-broadcasted_at', label: 'Desc Broadcasting At'},
        {id: '-created_at', label: 'Desc Created At'},
        {id: '-updated_at', label: 'Desc Updated At'},
      ]
    }
  ]

  selectedChannels = []
  selectedOrder = '-broadcasted_at'
  live = false
  integrale = false

  dateRange = new DateRange()

  pageEvent: PageEvent
  videos: CatalogPage

  selectedVideos = []

  constructor(
    public authService: AuthService,
    private rdfService: RdfService,
    private catalogService: CatalogService,
    private workflowService: WorkflowService,
    private snackBar: MatSnackBar,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.technician = this.authService.hasTechnicianRight()
    this.ftvstudio = this.authService.hasFtvStudioRight()

    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.pageSize = +params['per_page'] || 10
        var channels = params['channels']
        if (channels && !Array.isArray(channels)){
          channels = [channels]
        }
        this.selectedChannels = channels || []
        this.searchInput = params['search'] || ''
        if (params['broadcasted_after']) {
          this.dateRange.setStartDate(moment(params['broadcasted_after'], 'YYYY-MM-DD'))
        }
        if (params['broadcasted_before']) {
          this.dateRange.setEndDate(moment(params['broadcasted_before'], 'YYYY-MM-DD'))
        }
        if (params['video_id'] && params['video_id'].length === 36) {
          this.videoid = params['video_id']
        }
        this.getVideos(this.page)
      })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getVideos(index): void {
    this.loading = true
    this.catalogService.getVideos(index,
      this.pageSize,
      this.selectedChannels,
      this.searchInput,
      this.dateRange,
      this.videoid,
      this.live,
      this.integrale,
      this.selectedOrder)
    .subscribe(videoPage => {
      this.loading = false
      this.selectedVideos = []

      if (videoPage === undefined) {
        this.videos = new CatalogPage()
        this.length = undefined
        return
      }

      this.videos = videoPage
      this.length = videoPage.total
    })
  }

  eventGetVideos(event): void {
    this.router.navigate(['/catalog'], { queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize) })
  }

  updateVideos(): void {
    this.router.navigate(['/catalog'], { queryParams: this.getQueryParamsForPage(0) })
    this.getVideos(0)
  }

  updateSearchByVideoId(): void {
    if (this.videoid.length === 36) {
      this.getVideos(0)
    }
  }

  getQueryParamsForPage(pageIndex: number, pageSize: number = undefined): Object {
    var params = {}

    if (this.selectedChannels.length !== 0) {
      params['channels'] = this.selectedChannels
    }
    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    if (this.searchInput !== '') {
      params['search'] = this.searchInput
    }
    if (this.dateRange.getStart() !== undefined) {
      params['broadcasted_after'] = this.dateRange.getStart().format('YYYY-MM-DD')
    }
    if (this.dateRange.getEnd() !== undefined) {
      params['broadcasted_before'] = this.dateRange.getEnd().format('YYYY-MM-DD')
    }
    if (this.videoid && this.videoid.length === 36) {
      params['video_id'] = this.videoid
    }
    if (pageSize) {
      if (pageSize !== 10) {
        params['per_page'] = pageSize
      }
    } else {
      if (this.pageSize !== 10) {
        params['per_page'] = this.pageSize
      }
    }
    return params
  }

  setStartDate(event): void {
    this.dateRange.setStartDate(event.value)
    this.getQueryParamsForPage(0)
    this.updateVideos()
  }

  setEndDate(event): void {
    this.dateRange.setEndDate(event.value)
    this.getQueryParamsForPage(0)
    this.updateVideos()
  }

  updateStart(): void {
    this.getQueryParamsForPage(0)
    this.updateVideos()
  }

  updateEnd(): void {
    this.getQueryParamsForPage(0)
    this.updateVideos()
  }

  selectVideo(video, checked) {
    video.selected = checked
    if (checked) {
      this.selectedVideos.push(video)
    } else {
      this.selectedVideos = this.selectedVideos.filter(v => v.id !== video.id)
    }
  }

  selectAllVideos(event) {
    for (let video of this.videos.data) {
      if (video.available) {
        this.selectVideo(video, event.checked)
      }
    }
  }

  start_process(video) {
    let dialogRef = this.dialog.open(WorkflowDialogComponent, {
      data: {
        'broadcasted_live': video.broadcasted_live,
        'reference': video.id
      }
    })

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        workflow.reference = video.id
        this.workflowService.createWorkflow(workflow)
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  start_ftvstudio_ingest(video) {
    this.workflowService.getWorkflowDefinition("ftv_studio_rosetta", video.id)
      .subscribe(workflowDefinition => {
        workflowDefinition.reference = video.id
        this.workflowService.createWorkflow(workflowDefinition)
          .subscribe(response => {
            let snackBarRef = this.snackBar.open("Rosetta ingest started for \"" + video.title + "\"", "Show workflow", {
              duration: 4000,
            })

            snackBarRef.onAction().subscribe(() => {
              this.router.navigate(['/workflows/' +  response.data.id])
            });
          })
      })
  }

  start_all_process() {
    let dialogRef = this.dialog.open(WorkflowDialogComponent, {})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        for (let video of this.selectedVideos) {
          workflow.reference = video.id
          this.workflowService.createWorkflow(workflow)
          .subscribe(response => {
            console.log(response)
          })
        }
      }
    })
  }

  get_encoded_uri(uri): string {
    return encodeURI('[\"' + uri + '\"]')
  }

  show_rdf(video): void {
    this.rdfService.getRdf(video.id)
    .subscribe(response => {
      if (response) {
        let dialogRef = this.dialog.open(RdfDialogComponent, {
          data: {
            rdf: response.content
          }
        })

        dialogRef.afterClosed().subscribe(steps => {})
      }
    })
  }

  ingest_rdf(video): void {
    console.log('RDF ingest ', video.id)

    this.rdfService.ingestRdf(video.id)
    .subscribe(response => {
      console.log(response)
    })
  }

  gotoRelatedWorkflows(video_id): void {
    this.router.navigate(['/workflows'], { queryParams: {video_id: video_id} })
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/catalog'], { queryParams: {video_id: video_id} })
  }
}
