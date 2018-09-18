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

@Pipe({name: 'tenure'})
export class TenurePipe implements PipeTransform {
  transform(dates:Array<string|number>) : string {
    if(dates.length == 2) {
      let startdate= dates[0]; 
      let enddate=dates[1];
      if(startdate && enddate) {
        if(startdate != enddate)
          return startdate + "-" + enddate;
        else return ""+startdate;
      } else {
        if(startdate)
          return ""+startdate;
        else if(enddate)
          return ""+enddate;
        else return "";
      }
    }
    return "";
  }
} 

@Pipe({name: 'highlight'})
export class HighlightPipe implements PipeTransform {
  transform(items: any[], filterHighlighted = true): any {
    if(filterHighlighted) {
      return items.filter(item => item.highlight == "yes");
    } else {
      return items.filter(item => item.highlight != "yes");
    }
      
  }
}

@Pipe({name: 'coauthors'})
export class CoAuthorsPipe implements PipeTransform {
  static me = "";
  transform(authors: Array<string>): string {
    if(authors) {
      let res = "(joint work with "
      let marker = false; //ensuring at least one author is added to the list
      for(let person of authors) {
        if(person != CoAuthorsPipe.me) {
          res = res + person + ", ";
          marker = true;
        }
      }
      res = res.substr(0, res.length-2);
      let i = res.lastIndexOf(",");
      res=res.replace(/,([^,]*)$/," &"+'$1'); 
      if(marker)
        return res + ")";
      else return "";
    }
    else {return ""};
  }
}