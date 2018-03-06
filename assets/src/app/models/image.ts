
export class ImageParameters {
  Image: string;
  Env: string[];
  HostConfig: Object;
}

export class Image {
  name: string;
  label: string;
  params: ImageParameters
}
