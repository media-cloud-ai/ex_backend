
export enum LinkLabels {
  facebook = "Facebook",
  imdb = "IMDb",
  linkedin = "LinkedIn",
}

export class Link {
  label: string;
  url: string;
}

export class Links {
  facebook: string;
  imdb: string;
  linkedin: string;

  constructor(links: Link[]) {
    for(let link of links) {
      switch(link.label) {
        case LinkLabels.facebook:
          this.facebook = link.url;
          break;
        case LinkLabels.imdb:
          this.imdb = link.url;
          break;
        case LinkLabels.linkedin:
          this.linkedin = link.url;
          break;
      }
    }
  }

  public static toLinksArray(links: Links): Link[] {
    return [
      { label: LinkLabels.imdb, url: links.imdb },
      { label: LinkLabels.linkedin, url: links.linkedin },
      { label: LinkLabels.facebook, url: links.facebook },
    ];
  }

}

export class Person {
  id: number;
  last_name: string;
  first_names: any;
  gender: string;
  birth_date: string;
  birth_city: string;
  birth_country: string;
  nationalities: any;
  links: Links;
}
