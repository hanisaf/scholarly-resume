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

@Pipe({name: 'money'})
export class MoneyPipe implements PipeTransform {
  transform(value:number) : string {
    if(value) {
      return "($"+value+")";
    } else {return "";}
    
  }
} 

@Pipe({name: 'coauthors'})
export class CoAuthorsPipe implements PipeTransform {
  static me = "";
  transform(authors: Array<string>): string {
    if(authors) {
      let res = "(joint work with "
      for(let person of authors) {
        if(person != CoAuthorsPipe.me) {
          res = res + person + ", ";
        }
      }
      res = res.substr(0, res.length-2);
      let i = res.lastIndexOf(",");
      res=res.replace(/,([^,]*)$/," &"+'$1'); 
      return res + ")";
    }
    else {return ""};
  }
}