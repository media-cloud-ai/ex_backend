
export class ImageParameters {
  Image: string;
  Env: string[];
  HostConfig: Object;
}

export class Image {
  id: string;
  label: string;
  params: ImageParameters
}
