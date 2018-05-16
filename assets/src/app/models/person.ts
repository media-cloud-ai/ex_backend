
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
  first_names: string[];
  gender: string;
  birth_date: string;
  birth_city: string;
  birth_country: string;
  nationalities: string[];
  links: Links;

  constructor() {
    this.first_names = new Array<string>("");
    this.nationalities = new Array<string>();
  }
}

export class IMDbPeople {
  name: string;
  birth_date: string;
  birth_location: string;
  picture_url: string;
}
