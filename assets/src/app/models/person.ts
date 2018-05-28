
export enum LinkLabel {
  facebook = "Facebook",
  imdb = "IMDb",
  linkedin = "LinkedIn",
}

export class Links {
  imdb?: string;
  facebook?: string;
  linkedin?: string;
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
    this.gender = "Unknown";
    this.first_names = new Array<string>("");
    this.nationalities = new Array<string>();
    this.links = new Links;
  }
}

export class IMDbPeople {
  name: string;
  birth_date: string;
  birth_location: string;
  picture_url: string;
}
