import { PipeTransform, Pipe } from '@angular/core';

@Pipe({name: 'keys'})
export class KeysPipe implements PipeTransform {
  transform(value, args:string[]) : any {
    let keys = [];
    for (let key in value) {
      keys.push({key: key, value: value[key]});
    }
    return keys;
  }
} 

@Pipe({name: 'cites'})
export class CitesPipe implements PipeTransform {
  transform(value, args:string[]) : any {
    return `<a href="${value.url}">${value.url}</a>`;
  }
} 